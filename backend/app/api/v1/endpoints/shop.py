from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.api.dependencies import get_current_user 

import uuid
from datetime import datetime

from typing import List, Optional
from app.database.base import get_db
from app.schemas.shop import (
    ShopCategory, ShopCategoryCreate,
    ShopProduct, ShopProductCreate, ShopProductUpdate,
    Cart, CartItem, CartItemCreate, CartItemUpdate,
    Order, OrderCreate,
    ProductReview, ProductReviewCreate
)
from app.models_db import (
    ShopCategory as ShopCategoryModel,
    ShopProduct as ShopProductModel,
    Cart as CartModel,
    CartItem as CartItemModel,
    Order as OrderModel,
    OrderItem as OrderItemModel,
    ProductReview as ProductReviewModel,
    User
)

router = APIRouter()


@router.get("/categories", response_model=List[ShopCategory])
def get_categories(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Get all active shop categories"""
    categories = db.query(ShopCategoryModel).filter(
        ShopCategoryModel.is_active == True
    ).offset(skip).limit(limit).all()
    return categories

@router.post("/categories", response_model=ShopCategory)
def create_category(
    category: ShopCategoryCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new shop category (admin only)"""
    
    
    
    
    db_category = ShopCategoryModel(**category.dict())
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category


@router.get("/products", response_model=List[ShopProduct])
def get_products(
    skip: int = 0,
    limit: int = 20,
    category_id: Optional[int] = None,
    search: Optional[str] = None,
    is_featured: Optional[bool] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    db: Session = Depends(get_db)
):
    """Get products with filtering options"""
    query = db.query(ShopProductModel).filter(ShopProductModel.is_active == True)
    
    if category_id:
        query = query.filter(ShopProductModel.category_id == category_id)
    
    if search:
        query = query.filter(ShopProductModel.name.ilike(f"%{search}%"))
    
    if is_featured is not None:
        query = query.filter(ShopProductModel.is_featured == is_featured)
    
    if min_price is not None:
        query = query.filter(ShopProductModel.price >= min_price)
    
    if max_price is not None:
        query = query.filter(ShopProductModel.price <= max_price)
    
    products = query.offset(skip).limit(limit).all()
    
    return products

@router.get("/products/featured", response_model=List[ShopProduct])
def get_featured_products(
    limit: int = 10,
    db: Session = Depends(get_db)
):
    """Get featured products"""
    products = db.query(ShopProductModel).filter(
        ShopProductModel.is_active == True,
        ShopProductModel.is_featured == True
    ).limit(limit).all()
    return products

@router.get("/products/{product_id}", response_model=ShopProduct)
def get_product(product_id: int, db: Session = Depends(get_db)):
    """Get a specific product by ID"""
    product = db.query(ShopProductModel).filter(
        ShopProductModel.id == product_id,
        ShopProductModel.is_active == True
    ).first()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    return product

@router.post("/products", response_model=ShopProduct)
def create_product(
    product: ShopProductCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new product (admin only)"""
    
    
    
    
    db_product = ShopProductModel(**product.dict())
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    return db_product

@router.put("/products/{product_id}", response_model=ShopProduct)
def update_product(
    product_id: int,
    product_update: ShopProductUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update a product (admin only)"""
    
    
    
    
    db_product = db.query(ShopProductModel).filter(
        ShopProductModel.id == product_id
    ).first()
    
    if not db_product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    update_data = product_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_product, field, value)
    
    db_product.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(db_product)
    return db_product


@router.get("/cart", response_model=Cart)
def get_cart(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's shopping cart"""
    cart = db.query(CartModel).filter(CartModel.user_id == current_user.id).first()
    
    if not cart:
        
        cart = CartModel(user_id=current_user.id)
        db.add(cart)
        db.commit()
        db.refresh(cart)
    
    return cart

@router.post("/cart/items", response_model=CartItem)
def add_to_cart(
    item: CartItemCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Add item to cart"""
    
    product = db.query(ShopProductModel).filter(
        ShopProductModel.id == item.product_id,
        ShopProductModel.is_active == True
    ).first()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    
    if product.stock_quantity < item.quantity:
        raise HTTPException(status_code=400, detail="Insufficient stock")
    
    
    cart = db.query(CartModel).filter(CartModel.user_id == current_user.id).first()
    if not cart:
        cart = CartModel(user_id=current_user.id)
        db.add(cart)
        db.commit()
        db.refresh(cart)
    
    
    existing_item = db.query(CartItemModel).filter(
        CartItemModel.cart_id == cart.id,
        CartItemModel.product_id == item.product_id
    ).first()
    
    if existing_item:
        
        new_quantity = existing_item.quantity + item.quantity
        if product.stock_quantity < new_quantity:
            raise HTTPException(status_code=400, detail="Insufficient stock")
        
        existing_item.quantity = new_quantity
        db.commit()
        db.refresh(existing_item)
        return existing_item
    else:
        
        cart_item = CartItemModel(
            cart_id=cart.id,
            product_id=item.product_id,
            quantity=item.quantity
        )
        db.add(cart_item)
        db.commit()
        db.refresh(cart_item)
        return cart_item

@router.put("/cart/items/{item_id}", response_model=CartItem)
def update_cart_item(
    item_id: int,
    item_update: CartItemUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update cart item quantity"""
    cart_item = db.query(CartItemModel).join(CartModel).filter(
        CartItemModel.id == item_id,
        CartModel.user_id == current_user.id
    ).first()
    
    if not cart_item:
        raise HTTPException(status_code=404, detail="Cart item not found")
    
    
    if cart_item.product.stock_quantity < item_update.quantity:
        raise HTTPException(status_code=400, detail="Insufficient stock")
    
    cart_item.quantity = item_update.quantity
    db.commit()
    db.refresh(cart_item)
    return cart_item

@router.delete("/cart/items/{item_id}")
def remove_from_cart(
    item_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Remove item from cart"""
    cart_item = db.query(CartItemModel).join(CartModel).filter(
        CartItemModel.id == item_id,
        CartModel.user_id == current_user.id
    ).first()
    
    if not cart_item:
        raise HTTPException(status_code=404, detail="Cart item not found")
    
    db.delete(cart_item)
    db.commit()
    return {"message": "Item removed from cart"}

@router.delete("/cart/clear")
def clear_cart(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Clear all items from cart"""
    cart = db.query(CartModel).filter(CartModel.user_id == current_user.id).first()
    
    if cart:
        
        db.query(CartItemModel).filter(CartItemModel.cart_id == cart.id).delete()
        db.commit()
    
    return {"message": "Cart cleared"}


@router.post("/orders", response_model=Order)
def create_order(
    order_data: OrderCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create order from cart items"""
    
    cart = db.query(CartModel).filter(CartModel.user_id == current_user.id).first()
    
    if not cart or not cart.items:
        raise HTTPException(status_code=400, detail="Cart is empty")
    
    
    for cart_item in cart.items:
        if cart_item.product.stock_quantity < cart_item.quantity:
            raise HTTPException(
                status_code=400, 
                detail=f"Insufficient stock for {cart_item.product.name}"
            )
    
    
    total_amount = sum(
        (item.product.sale_price or item.product.price) * item.quantity 
        for item in cart.items
    )
    
    
    order = OrderModel(
        user_id=current_user.id,
        order_number=f"ORD-{uuid.uuid4().hex[:8].upper()}",
        total_amount=total_amount,
        shipping_address=order_data.shipping_address,
        payment_method=order_data.payment_method
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    
    
    for cart_item in cart.items:
        order_item = OrderItemModel(
            order_id=order.id,
            product_id=cart_item.product_id,
            quantity=cart_item.quantity,
            price=cart_item.product.sale_price or cart_item.product.price
        )
        db.add(order_item)
        
        
        cart_item.product.stock_quantity -= cart_item.quantity
    
    
    for cart_item in cart.items:
        db.delete(cart_item)
    
    db.commit()
    db.refresh(order)
    return order

@router.get("/orders", response_model=List[Order])
def get_user_orders(
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's orders"""
    orders = db.query(OrderModel).filter(
        OrderModel.user_id == current_user.id
    ).order_by(OrderModel.created_at.desc()).offset(skip).limit(limit).all()
    return orders

@router.get("/orders/{order_id}", response_model=Order)
def get_order(
    order_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get specific order"""
    order = db.query(OrderModel).filter(
        OrderModel.id == order_id,
        OrderModel.user_id == current_user.id
    ).first()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    return order


@router.post("/products/{product_id}/reviews", response_model=ProductReview)
def create_review(
    product_id: int,
    review: ProductReviewCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create product review"""
    
    product = db.query(ShopProductModel).filter(
        ShopProductModel.id == product_id,
        ShopProductModel.is_active == True
    ).first()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    
    existing_review = db.query(ProductReviewModel).filter(
        ProductReviewModel.product_id == product_id,
        ProductReviewModel.user_id == current_user.id
    ).first()
    
    if existing_review:
        raise HTTPException(status_code=400, detail="You have already reviewed this product")
    
    
    has_purchased = db.query(OrderItemModel).join(OrderModel).filter(
        OrderModel.user_id == current_user.id,
        OrderItemModel.product_id == product_id,
        OrderModel.payment_status == "paid"
    ).first()
    
    db_review = ProductReviewModel(
        product_id=product_id,
        user_id=current_user.id,
        rating=review.rating,
        comment=review.comment,
        is_verified_purchase=bool(has_purchased)
    )
    db.add(db_review)
    db.commit()
    db.refresh(db_review)
    
    
    _update_product_rating(product_id, db)
    
    return db_review

@router.get("/products/{product_id}/reviews", response_model=List[ProductReview])
def get_product_reviews(
    product_id: int,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """Get product reviews"""
    reviews = db.query(ProductReviewModel).filter(
        ProductReviewModel.product_id == product_id
    ).order_by(ProductReviewModel.created_at.desc()).offset(skip).limit(limit).all()
    return reviews

def _update_product_rating(product_id: int, db: Session):
    """Helper function to update product rating and review count"""
    reviews = db.query(ProductReviewModel).filter(
        ProductReviewModel.product_id == product_id
    ).all()
    
    if reviews:
        avg_rating = sum(review.rating for review in reviews) / len(reviews)
        
        product = db.query(ShopProductModel).filter(
            ShopProductModel.id == product_id
        ).first()
        
        if product:
            product.rating = round(avg_rating, 1)
            product.review_count = len(reviews)
            db.commit()
