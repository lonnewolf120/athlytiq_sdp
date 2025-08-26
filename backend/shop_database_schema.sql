
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===================================================================
-- SHOP CATEGORIES TABLE
-- ===================================================================
CREATE TABLE IF NOT EXISTS shop_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(1024),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Indexes
    CONSTRAINT unique_category_name UNIQUE(name)
);

CREATE INDEX IF NOT EXISTS idx_shop_categories_active ON shop_categories(is_active);
CREATE INDEX IF NOT EXISTS idx_shop_categories_name ON shop_categories(name);

-- ===================================================================
-- SHOP PRODUCTS TABLE
-- ===================================================================
CREATE TABLE IF NOT EXISTS shop_products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    sale_price DECIMAL(10,2) CHECK (sale_price >= 0 AND sale_price <= price),
    image_urls JSONB DEFAULT '[]', -- Array of image URLs
    category_id INTEGER NOT NULL,
    brand VARCHAR(255),
    sku VARCHAR(100) UNIQUE,
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    rating DECIMAL(3,2) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    review_count INTEGER DEFAULT 0 CHECK (review_count >= 0),
    tags JSONB DEFAULT '[]', -- Array of tags for filtering
    specifications JSONB DEFAULT '{}', -- Product specifications as JSON
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT fk_product_category 
        FOREIGN KEY (category_id) 
        REFERENCES shop_categories(id) 
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_shop_products_category ON shop_products(category_id);
CREATE INDEX IF NOT EXISTS idx_shop_products_active ON shop_products(is_active);
CREATE INDEX IF NOT EXISTS idx_shop_products_featured ON shop_products(is_featured);
CREATE INDEX IF NOT EXISTS idx_shop_products_price ON shop_products(price);
CREATE INDEX IF NOT EXISTS idx_shop_products_rating ON shop_products(rating);
CREATE INDEX IF NOT EXISTS idx_shop_products_name ON shop_products USING gin(to_tsvector('english', name));
CREATE INDEX IF NOT EXISTS idx_shop_products_tags ON shop_products USING gin(tags);
CREATE INDEX IF NOT EXISTS idx_shop_products_brand ON shop_products(brand);
CREATE INDEX IF NOT EXISTS idx_shop_products_sku ON shop_products(sku);

-- ===================================================================
-- SHOPPING CARTS TABLE
-- ===================================================================
CREATE TABLE IF NOT EXISTS carts (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_cart_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
    
    CONSTRAINT unique_user_cart UNIQUE(user_id)
);

-- Indexes for carts
CREATE INDEX IF NOT EXISTS idx_carts_user ON carts(user_id);

-- ===================================================================
-- CART ITEMS TABLE
-- ===================================================================
CREATE TABLE IF NOT EXISTS cart_items (
    id SERIAL PRIMARY KEY,
    cart_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_cart_item_cart 
        FOREIGN KEY (cart_id) 
        REFERENCES carts(id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_cart_item_product 
        FOREIGN KEY (product_id) 
        REFERENCES shop_products(id) 
        ON DELETE CASCADE,
    
    CONSTRAINT unique_cart_product UNIQUE(cart_id, product_id)
);

-- Indexes for cart_items
CREATE INDEX IF NOT EXISTS idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product ON cart_items(product_id);

-- ===================================================================
-- ORDERS TABLE
-- ===================================================================
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    order_number VARCHAR(100) NOT NULL UNIQUE,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
    shipping_address JSONB NOT NULL, -- Shipping address as JSON
    payment_method VARCHAR(100),
    payment_status VARCHAR(50) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded', 'cancelled')),
    payment_reference VARCHAR(255), -- Payment gateway reference
    notes TEXT, -- Order notes/instructions
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_order_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE
);

-- Indexes for orders
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_order_number ON orders(order_number);

-- ===================================================================
-- ORDER ITEMS TABLE
-- ===================================================================
CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0), -- Price at time of order
    total_price DECIMAL(12,2) GENERATED ALWAYS AS (quantity * price) STORED,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_order_item_order 
        FOREIGN KEY (order_id) 
        REFERENCES orders(id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_order_item_product 
        FOREIGN KEY (product_id) 
        REFERENCES shop_products(id) 
        ON DELETE RESTRICT 
);

-- Indexes for order_items
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON order_items(product_id);

-- ===================================================================
-- PRODUCT REVIEWS TABLE
-- ===================================================================
CREATE TABLE IF NOT EXISTS product_reviews (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    user_id UUID NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT TRUE, -- For review moderation
    helpful_count INTEGER DEFAULT 0 CHECK (helpful_count >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_review_product 
        FOREIGN KEY (product_id) 
        REFERENCES shop_products(id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_review_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
    
    CONSTRAINT unique_user_product_review UNIQUE(product_id, user_id)
);

-- Indexes for product_reviews
CREATE INDEX IF NOT EXISTS idx_product_reviews_product ON product_reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_product_reviews_user ON product_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_product_reviews_rating ON product_reviews(rating);
CREATE INDEX IF NOT EXISTS idx_product_reviews_approved ON product_reviews(is_approved);
CREATE INDEX IF NOT EXISTS idx_product_reviews_verified ON product_reviews(is_verified_purchase);

-- ===================================================================
-- ADDITIONAL TABLES (OPTIONAL - FOR FUTURE ENHANCEMENTS)
-- ===================================================================

-- WISHLIST TABLE
CREATE TABLE IF NOT EXISTS wishlists (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    product_id INTEGER NOT NULL,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_wishlist_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_wishlist_product 
        FOREIGN KEY (product_id) 
        REFERENCES shop_products(id) 
        ON DELETE CASCADE,
    
    CONSTRAINT unique_user_wishlist_product UNIQUE(user_id, product_id)
);

-- Indexes for wishlists
CREATE INDEX IF NOT EXISTS idx_wishlists_user ON wishlists(user_id);
CREATE INDEX IF NOT EXISTS idx_wishlists_product ON wishlists(product_id);

-- DISCOUNT CODES TABLE
CREATE TABLE IF NOT EXISTS discount_codes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    discount_type VARCHAR(20) CHECK (discount_type IN ('percentage', 'fixed_amount')),
    discount_value DECIMAL(10,2) NOT NULL CHECK (discount_value > 0),
    minimum_order_amount DECIMAL(10,2) DEFAULT 0,
    maximum_discount_amount DECIMAL(10,2),
    usage_limit INTEGER,
    used_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CHECK (valid_until IS NULL OR valid_until > valid_from),
    CHECK (usage_limit IS NULL OR usage_limit > 0),
    CHECK (used_count >= 0),
    CHECK (used_count <= COALESCE(usage_limit, used_count + 1))
);

-- Indexes for discount_codes
CREATE INDEX IF NOT EXISTS idx_discount_codes_active ON discount_codes(is_active);
CREATE INDEX IF NOT EXISTS idx_discount_codes_valid_dates ON discount_codes(valid_from, valid_until);

-- ===================================================================
-- TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- ===================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at columns
CREATE TRIGGER update_shop_products_updated_at 
    BEFORE UPDATE ON shop_products 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_carts_updated_at 
    BEFORE UPDATE ON carts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at 
    BEFORE UPDATE ON orders 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===================================================================
-- FUNCTIONS FOR PRODUCT RATING CALCULATIONS
-- ===================================================================

CREATE OR REPLACE FUNCTION update_product_rating(product_id_param INTEGER)
RETURNS VOID AS $$
DECLARE
    avg_rating DECIMAL(3,2);
    total_reviews INTEGER;
BEGIN
    SELECT 
        ROUND(AVG(rating)::NUMERIC, 2),
        COUNT(*)
    INTO avg_rating, total_reviews
    FROM product_reviews 
    WHERE product_id = product_id_param 
    AND is_approved = TRUE;
    
    UPDATE shop_products 
    SET 
        rating = COALESCE(avg_rating, 0),
        review_count = total_reviews
    WHERE id = product_id_param;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trigger_update_product_rating()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        PERFORM update_product_rating(OLD.product_id);
        RETURN OLD;
    ELSE
        PERFORM update_product_rating(NEW.product_id);
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER product_review_rating_trigger
    AFTER INSERT OR UPDATE OR DELETE ON product_reviews
    FOR EACH ROW EXECUTE FUNCTION trigger_update_product_rating();

-- ===================================================================
-- SAMPLE DATA INSERTION (OPTIONAL)
-- ===================================================================

-- Insert sample categories
INSERT INTO shop_categories (name, description, image_url) VALUES
('Protein Supplements', 'High-quality protein powders and supplements for muscle building and recovery', 'https://example.com/images/protein-category.jpg'),
('Pre-Workout', 'Energy boosting supplements to maximize your workout performance', 'https://example.com/images/preworkout-category.jpg'),
('Fitness Equipment', 'Essential equipment for home and gym workouts', 'https://example.com/images/equipment-category.jpg'),
('Fitness Apparel', 'High-performance workout clothing and accessories', 'https://example.com/images/apparel-category.jpg'),
('Vitamins & Health', 'Essential vitamins and health supplements for overall wellness', 'https://example.com/images/vitamins-category.jpg')
ON CONFLICT (name) DO NOTHING;

-- Insert sample products
INSERT INTO shop_products (name, description, price, sale_price, image_urls, category_id, brand, sku, stock_quantity, is_featured, tags, specifications) VALUES
('Whey Protein Isolate - Vanilla', 'Premium whey protein isolate with 25g protein per serving. Perfect for post-workout recovery and muscle building.', 59.99, 49.99, '["https://example.com/images/whey-vanilla.jpg"]', 1, 'FitNation', 'WPI-VAN-001', 50, true, '["protein", "whey", "vanilla", "isolate"]', '{"serving_size": "30g", "protein_per_serving": "25g", "flavors": ["Vanilla"], "weight": "2lbs"}'),
('Plant-Based Protein - Chocolate', 'Organic plant-based protein blend with 22g protein per serving. Suitable for vegans and vegetarians.', 54.99, null, '["https://example.com/images/plant-chocolate.jpg"]', 1, 'GreenFit', 'PBP-CHO-001', 30, false, '["protein", "plant-based", "chocolate", "vegan"]', '{"serving_size": "32g", "protein_per_serving": "22g", "flavors": ["Chocolate"], "weight": "2lbs"}'),
('Energy Boost Pre-Workout', 'High-energy pre-workout formula with caffeine, beta-alanine, and creatine for maximum performance.', 39.99, 34.99, '["https://example.com/images/preworkout-energy.jpg"]', 2, 'PowerMax', 'PWO-ENR-001', 75, true, '["pre-workout", "energy", "caffeine", "performance"]', '{"serving_size": "15g", "caffeine_content": "200mg", "servings_per_container": "30", "flavor": "Fruit Punch"}'),
('Adjustable Dumbbells Set', 'Professional adjustable dumbbells ranging from 5-50 lbs each. Perfect for home workouts.', 299.99, 249.99, '["https://example.com/images/dumbbells.jpg"]', 3, 'FlexFit', 'ADB-SET-001', 15, true, '["dumbbells", "adjustable", "home-gym", "strength"]', '{"weight_range": "5-50 lbs each", "material": "Cast Iron with Rubber Coating", "adjustment": "Quick-Lock System", "warranty": "2 years"}'),
('Performance Athletic T-Shirt', 'Moisture-wicking athletic t-shirt made with premium breathable fabric.', 24.99, 19.99, '["https://example.com/images/athletic-tshirt.jpg"]', 4, 'ActiveWear Pro', 'PAT-BLK-M', 200, false, '["t-shirt", "moisture-wicking", "athletic", "breathable"]', '{"material": "88% Polyester, 12% Spandex", "sizes": "S, M, L, XL, XXL", "color": "Black", "care": "Machine Washable"}')
ON CONFLICT (sku) DO NOTHING;

-- ===================================================================
-- VIEWS FOR COMMON QUERIES
-- ===================================================================

CREATE OR REPLACE VIEW active_products_view AS
SELECT 
    p.id,
    p.name,
    p.description,
    p.price,
    p.sale_price,
    COALESCE(p.sale_price, p.price) as effective_price,
    p.image_urls,
    p.brand,
    p.sku,
    p.stock_quantity,
    p.is_featured,
    p.rating,
    p.review_count,
    p.tags,
    p.specifications,
    p.created_at,
    p.updated_at,
    c.name as category_name,
    c.description as category_description
FROM shop_products p
JOIN shop_categories c ON p.category_id = c.id
WHERE p.is_active = true AND c.is_active = true;

CREATE OR REPLACE VIEW order_summary_view AS
SELECT 
    o.id,
    o.order_number,
    o.user_id,
    o.status,
    o.total_amount,
    o.payment_status,
    o.created_at,
    COUNT(oi.id) as item_count,
    SUM(oi.quantity) as total_quantity
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, o.order_number, o.user_id, o.status, o.total_amount, o.payment_status, o.created_at;



