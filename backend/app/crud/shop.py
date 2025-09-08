from sqlalchemy.orm import Session
from typing import List, Optional
from app.models_db import (
    ShopCategory, ShopProduct, Cart, CartItem, Order, OrderItem, ProductReview
)
from app.schemas.shop import (
    ShopCategoryCreate, ShopProductCreate, ShopProductUpdate,
    CartItemCreate, CartItemUpdate, OrderCreate, ProductReviewCreate
)


def get_categories(db: Session, skip: int = 0, limit: int = 100) -> List[ShopCategory]:
    return db.query(ShopCategory).filter(ShopCategory.is_active == True).offset(skip).limit(limit).all()

def get_category(db: Session, category_id: int) -> Optional[ShopCategory]:
    return db.query(ShopCategory).filter(ShopCategory.id == category_id).first()

def create_category(db: Session, category: ShopCategoryCreate) -> ShopCategory:
    db_category = ShopCategory(**category.dict())
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category


def get_products(
    db: Session, 
    skip: int = 0, 
    limit: int = 20,
    category_id: Optional[int] = None,
    search: Optional[str] = None,
    is_featured: Optional[bool] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None
) -> List[ShopProduct]:
    query = db.query(ShopProduct).filter(ShopProduct.is_active == True)
    
    if category_id:
        query = query.filter(ShopProduct.category_id == category_id)
    
    if search:
        query = query.filter(ShopProduct.name.ilike(f"%{search}%"))
    
    if is_featured is not None:
        query = query.filter(ShopProduct.is_featured == is_featured)
    
    if min_price is not None:
        query = query.filter(ShopProduct.price >= min_price)
    
    if max_price is not None:
        query = query.filter(ShopProduct.price <= max_price)
    
    return query.offset(skip).limit(limit).all()

def get_product(db: Session, product_id: int) -> Optional[ShopProduct]:
    return db.query(ShopProduct).filter(
        ShopProduct.id == product_id,
        ShopProduct.is_active == True
    ).first()

def create_product(db: Session, product: ShopProductCreate) -> ShopProduct:
    db_product = ShopProduct(**product.dict())
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    return db_product

def update_product(db: Session, product_id: int, product_update: ShopProductUpdate) -> Optional[ShopProduct]:
    db_product = db.query(ShopProduct).filter(ShopProduct.id == product_id).first()
    if not db_product:
        return None
    
    update_data = product_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_product, field, value)
    
    db.commit()
    db.refresh(db_product)
    return db_product


def get_user_cart(db: Session, user_id: str) -> Optional[Cart]:
    return db.query(Cart).filter(Cart.user_id == user_id).first()

def create_cart(db: Session, user_id: str) -> Cart:
    db_cart = Cart(user_id=user_id)
    db.add(db_cart)
    db.commit()
    db.refresh(db_cart)
    return db_cart

def add_to_cart(db: Session, cart_id: int, item: CartItemCreate) -> CartItem:
    
    existing_item = db.query(CartItem).filter(
        CartItem.cart_id == cart_id,
        CartItem.product_id == item.product_id
    ).first()
    
    if existing_item:
        existing_item.quantity += item.quantity
        db.commit()
        db.refresh(existing_item)
        return existing_item
    else:
        db_item = CartItem(cart_id=cart_id, **item.dict())
        db.add(db_item)
        db.commit()
        db.refresh(db_item)
        return db_item

def update_cart_item(db: Session, item_id: int, user_id: str, item_update: CartItemUpdate) -> Optional[CartItem]:
    cart_item = db.query(CartItem).join(Cart).filter(
        CartItem.id == item_id,
        Cart.user_id == user_id
    ).first()
    
    if not cart_item:
        return None
    
    cart_item.quantity = item_update.quantity
    db.commit()
    db.refresh(cart_item)
    return cart_item

def remove_from_cart(db: Session, item_id: int, user_id: str) -> bool:
    cart_item = db.query(CartItem).join(Cart).filter(
        CartItem.id == item_id,
        Cart.user_id == user_id
    ).first()
    
    if not cart_item:
        return False
    
    db.delete(cart_item)
    db.commit()
    return True

def clear_cart(db: Session, user_id: str) -> bool:
    cart = db.query(Cart).filter(Cart.user_id == user_id).first()
    if not cart:
        return False
    
    db.query(CartItem).filter(CartItem.cart_id == cart.id).delete()
    db.commit()
    return True


def create_order(db: Session, user_id: str, order_data: OrderCreate, cart_items: List[CartItem]) -> Order:
    import uuid
    from datetime import datetime
    
    
    total_amount = sum(
        (item.product.sale_price or item.product.price) * item.quantity 
        for item in cart_items
    )
    
    
    db_order = Order(
        user_id=user_id,
        order_number=f"ORD-{uuid.uuid4().hex[:8].upper()}",
        total_amount=total_amount,
        shipping_address=order_data.shipping_address,
        payment_method=order_data.payment_method
    )
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    
    
    for cart_item in cart_items:
        order_item = OrderItem(
            order_id=db_order.id,
            product_id=cart_item.product_id,
            quantity=cart_item.quantity,
            price=cart_item.product.sale_price or cart_item.product.price
        )
        db.add(order_item)
        
        
        cart_item.product.stock_quantity -= cart_item.quantity
    
    db.commit()
    return db_order

def get_user_orders(db: Session, user_id: str, skip: int = 0, limit: int = 20) -> List[Order]:
    return db.query(Order).filter(
        Order.user_id == user_id
    ).order_by(Order.created_at.desc()).offset(skip).limit(limit).all()

def get_order(db: Session, order_id: int, user_id: str) -> Optional[Order]:
    return db.query(Order).filter(
        Order.id == order_id,
        Order.user_id == user_id
    ).first()


def create_review(db: Session, user_id: str, review_data: ProductReviewCreate) -> ProductReview:
    
    has_purchased = db.query(OrderItem).join(Order).filter(
        Order.user_id == user_id,
        OrderItem.product_id == review_data.product_id,
        Order.payment_status == "paid"
    ).first()
    
    db_review = ProductReview(
        user_id=user_id,
        is_verified_purchase=bool(has_purchased),
        **review_data.dict()
    )
    db.add(db_review)
    db.commit()
    db.refresh(db_review)
    
    
    _update_product_rating(db, review_data.product_id)
    
    return db_review

def get_product_reviews(db: Session, product_id: int, skip: int = 0, limit: int = 20) -> List[ProductReview]:
    return db.query(ProductReview).filter(
        ProductReview.product_id == product_id
    ).order_by(ProductReview.created_at.desc()).offset(skip).limit(limit).all()

def _update_product_rating(db: Session, product_id: int):
    """Update product rating and review count"""
    reviews = db.query(ProductReview).filter(ProductReview.product_id == product_id).all()
    
    if reviews:
        avg_rating = sum(review.rating for review in reviews) / len(reviews)
        
        product = db.query(ShopProduct).filter(ShopProduct.id == product_id).first()
        if product:
            product.rating = round(avg_rating, 1)
            product.review_count = len(reviews)
            db.commit()
