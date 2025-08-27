from pydantic import BaseModel, Field, computed_field
from typing import List, Optional, Union
from datetime import datetime
from uuid import UUID


class ShopCategoryBase(BaseModel):
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    is_active: bool = True

class ShopCategoryCreate(ShopCategoryBase):
    pass

class ShopCategory(ShopCategoryBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True


class ShopProductBase(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    sale_price: Optional[float] = None
    image_urls: Optional[List[str]] = []
    category_id: int
    brand: Optional[str] = None
    sku: Optional[str] = None
    stock_quantity: int = 0
    is_active: bool = True
    is_featured: bool = False
    tags: Optional[List[str]] = []
    specifications: Optional[dict] = {}

class ShopProductCreate(ShopProductBase):
    pass

class ShopProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    sale_price: Optional[float] = None
    image_urls: Optional[List[str]] = None
    brand: Optional[str] = None
    stock_quantity: Optional[int] = None
    is_active: Optional[bool] = None
    is_featured: Optional[bool] = None
    tags: Optional[List[str]] = None
    specifications: Optional[dict] = None

class ShopProduct(ShopProductBase):
    id: int
    rating: float
    review_count: int
    created_at: datetime
    updated_at: datetime
    category: Optional[ShopCategory] = None
    
    class Config:
        from_attributes = True


class CartItemBase(BaseModel):
    product_id: int
    quantity: int

class CartItemCreate(CartItemBase):
    pass

class CartItemUpdate(BaseModel):
    quantity: int

class CartItem(CartItemBase):
    id: int
    added_at: datetime
    product: ShopProduct
    
    class Config:
        from_attributes = True

class Cart(BaseModel):
    id: int
    user_id: Union[str, UUID]
    items: List[CartItem]
    created_at: datetime
    updated_at: datetime
    
    @computed_field
    @property
    def total_amount(self) -> float:
        """Calculate total amount from all cart items"""
        return sum(
            item.quantity * (item.product.sale_price or item.product.price) 
            for item in self.items
        )
    
    class Config:
        from_attributes = True
        json_encoders = {
            UUID: str
        }


class OrderItemBase(BaseModel):
    product_id: int
    quantity: int
    price: float

class OrderItem(OrderItemBase):
    id: int
    product: ShopProduct
    
    class Config:
        from_attributes = True

class OrderCreate(BaseModel):
    shipping_address: dict
    payment_method: str

class Order(BaseModel):
    id: int
    user_id: Union[str, UUID]
    order_number: str
    status: str
    total_amount: float
    shipping_address: dict
    payment_method: str
    payment_status: str
    items: List[OrderItem]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
        json_encoders = {
            UUID: str
        }


class ProductReviewBase(BaseModel):
    product_id: int
    rating: int
    comment: Optional[str] = None

class ProductReviewCreate(ProductReviewBase):
    pass

class ProductReview(ProductReviewBase):
    id: int
    user_id: Union[str, UUID]
    is_verified_purchase: bool
    created_at: datetime
    
    class Config:
        from_attributes = True
        json_encoders = {
            UUID: str
        }
