-- OilMate Database Schema for Supabase
-- Complete car oil recommendation system with comprehensive vehicle data

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Vehicles Table
CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vin VARCHAR(17) NOT NULL UNIQUE,
    make VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL,
    engine_type VARCHAR(100),
    engine_displacement DECIMAL(3,1),
    transmission VARCHAR(100),
    fuel_type VARCHAR(50),
    region VARCHAR(50) NOT NULL DEFAULT 'Unknown',
    is_modified BOOLEAN DEFAULT FALSE,
    modifications TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_vin_length CHECK (LENGTH(vin) = 17),
    CONSTRAINT valid_year CHECK (year >= 1900 AND year <= 2030),
    CONSTRAINT valid_region CHECK (region IN ('USA', 'Middle East', 'China', 'Europe', 'Asia', 'Africa', 'Australia', 'South America', 'Unknown'))
);

-- Engine Specifications Table
CREATE TABLE engine_specifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    engine_code VARCHAR(50),
    engine_family VARCHAR(100),
    cylinders INTEGER,
    configuration VARCHAR(50), -- V, Inline, Boxer, etc.
    displacement DECIMAL(3,1),
    horsepower INTEGER,
    torque INTEGER,
    fuel_system VARCHAR(100),
    compression_ratio VARCHAR(20),
    valve_train VARCHAR(50),
    turbo_charged BOOLEAN DEFAULT FALSE,
    super_charged BOOLEAN DEFAULT FALSE,
    compatible_oil_types TEXT[], -- Array of compatible oil types
    technical_specs JSONB, -- Additional technical specifications
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_cylinders CHECK (cylinders > 0 AND cylinders <= 16),
    CONSTRAINT valid_displacement CHECK (displacement > 0),
    CONSTRAINT valid_horsepower CHECK (horsepower >= 0),
    CONSTRAINT valid_torque CHECK (torque >= 0)
);

-- Oil Specifications Table
CREATE TABLE oil_specifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    oil_type VARCHAR(20) NOT NULL, -- 0W-20, 5W-30, etc.
    viscosity_grade VARCHAR(50),
    capacity_with_filter DECIMAL(4,2) NOT NULL, -- Liters
    capacity_without_filter DECIMAL(4,2) NOT NULL, -- Liters
    recommended_brand VARCHAR(100),
    alternative_brands TEXT[], -- Array of alternative brands
    change_interval_km INTEGER NOT NULL,
    change_interval_months INTEGER NOT NULL,
    filter_part_number VARCHAR(50),
    drain_plug_torque VARCHAR(20),
    oil_spec_standard VARCHAR(50), -- API, ACEA, etc.
    additional_specs JSONB, -- Additional specifications
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_capacity_with_filter CHECK (capacity_with_filter > 0 AND capacity_with_filter <= 20),
    CONSTRAINT valid_capacity_without_filter CHECK (capacity_without_filter > 0 AND capacity_without_filter <= 20),
    CONSTRAINT valid_change_interval_km CHECK (change_interval_km > 0),
    CONSTRAINT valid_change_interval_months CHECK (change_interval_months > 0)
);

-- Maintenance Records Table
CREATE TABLE maintenance_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    vin VARCHAR(17) NOT NULL,
    service_type VARCHAR(100) NOT NULL,
    service_date DATE NOT NULL,
    mileage_at_service INTEGER NOT NULL,
    oil_type_used VARCHAR(20),
    oil_quantity DECIMAL(4,2),
    filter_used VARCHAR(100),
    service_location VARCHAR(200),
    cost DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    notes TEXT,
    additional_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_mileage CHECK (mileage_at_service >= 0),
    CONSTRAINT valid_oil_quantity CHECK (oil_quantity > 0),
    CONSTRAINT valid_cost CHECK (cost >= 0)
);

-- Car Models Database (for comprehensive car information)
CREATE TABLE car_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    make VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year_start INTEGER NOT NULL,
    year_end INTEGER,
    engine_variants JSONB, -- Array of engine configurations
    default_oil_spec JSONB, -- Default oil specifications
    region VARCHAR(50) NOT NULL,
    body_type VARCHAR(50),
    drive_type VARCHAR(20), -- FWD, RWD, AWD
    market_segment VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_year_range CHECK (year_start <= COALESCE(year_end, year_start))
);

-- Oil Products Database
CREATE TABLE oil_products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    brand VARCHAR(100) NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    oil_type VARCHAR(20) NOT NULL,
    viscosity VARCHAR(20) NOT NULL,
    specification VARCHAR(100),
    is_synthetic BOOLEAN DEFAULT FALSE,
    is_semi_synthetic BOOLEAN DEFAULT FALSE,
    is_conventional BOOLEAN DEFAULT FALSE,
    price_per_liter DECIMAL(8,2),
    currency VARCHAR(3) DEFAULT 'USD',
    availability_regions TEXT[],
    compatible_vehicles JSONB,
    performance_features TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Service Centers Database
CREATE TABLE service_centers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(200),
    specializations TEXT[], -- Toyota, BMW, etc.
    services_offered TEXT[], -- Oil change, filter replacement, etc.
    operating_hours JSONB,
    coordinates POINT, -- Geographic coordinates
    rating DECIMAL(2,1),
    is_certified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_vehicles_vin ON vehicles(vin);
CREATE INDEX idx_vehicles_make_model_year ON vehicles(make, model, year);
CREATE INDEX idx_vehicles_region ON vehicles(region);
CREATE INDEX idx_engine_specs_vehicle_id ON engine_specifications(vehicle_id);
CREATE INDEX idx_oil_specs_vehicle_id ON oil_specifications(vehicle_id);
CREATE INDEX idx_maintenance_records_vehicle_id ON maintenance_records(vehicle_id);
CREATE INDEX idx_maintenance_records_vin ON maintenance_records(vin);
CREATE INDEX idx_maintenance_records_service_date ON maintenance_records(service_date);
CREATE INDEX idx_car_models_make_model ON car_models(make, model);
CREATE INDEX idx_car_models_region ON car_models(region);
CREATE INDEX idx_oil_products_brand_type ON oil_products(brand, oil_type);
CREATE INDEX idx_service_centers_city_country ON service_centers(city, country);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers for updated_at
CREATE TRIGGER update_vehicles_updated_at BEFORE UPDATE ON vehicles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_engine_specifications_updated_at BEFORE UPDATE ON engine_specifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_oil_specifications_updated_at BEFORE UPDATE ON oil_specifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_car_models_updated_at BEFORE UPDATE ON car_models FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_oil_products_updated_at BEFORE UPDATE ON oil_products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_service_centers_updated_at BEFORE UPDATE ON service_centers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) - Enable for all tables
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE engine_specifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE oil_specifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE car_models ENABLE ROW LEVEL SECURITY;
ALTER TABLE oil_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_centers ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (adjust based on your security requirements)
CREATE POLICY "Allow public read access on vehicles" ON vehicles FOR SELECT USING (true);
CREATE POLICY "Allow public insert on vehicles" ON vehicles FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on vehicles" ON vehicles FOR UPDATE USING (true);

CREATE POLICY "Allow public read access on engine_specifications" ON engine_specifications FOR SELECT USING (true);
CREATE POLICY "Allow public insert on engine_specifications" ON engine_specifications FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public read access on oil_specifications" ON oil_specifications FOR SELECT USING (true);
CREATE POLICY "Allow public insert on oil_specifications" ON oil_specifications FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public read access on maintenance_records" ON maintenance_records FOR SELECT USING (true);
CREATE POLICY "Allow public insert on maintenance_records" ON maintenance_records FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public read access on car_models" ON car_models FOR SELECT USING (true);
CREATE POLICY "Allow public read access on oil_products" ON oil_products FOR SELECT USING (true);
CREATE POLICY "Allow public read access on service_centers" ON service_centers FOR SELECT USING (true);