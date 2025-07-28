-- Seed data for OilMate database
-- Comprehensive car models and oil specifications for real-world data

-- Insert popular car models with comprehensive information
INSERT INTO car_models (make, model, year_start, year_end, engine_variants, default_oil_spec, region, body_type, drive_type, market_segment) VALUES
-- Toyota Models
('Toyota', 'Camry', 2018, NULL, 
 '[
   {"engine": "2.5L 4-Cyl", "displacement": 2.5, "horsepower": 203, "torque": 184, "fuel": "Regular"},
   {"engine": "3.5L V6", "displacement": 3.5, "horsepower": 301, "torque": 267, "fuel": "Regular"}
 ]'::jsonb,
 '{"oil_type": "0W-20", "capacity_with_filter": 4.4, "capacity_without_filter": 4.0, "interval_km": 10000}'::jsonb,
 'USA', 'Sedan', 'FWD', 'Mid-size'),

('Toyota', 'Corolla', 2020, NULL,
 '[
   {"engine": "1.8L 4-Cyl", "displacement": 1.8, "horsepower": 139, "torque": 126, "fuel": "Regular"}
 ]'::jsonb,
 '{"oil_type": "0W-20", "capacity_with_filter": 4.2, "capacity_without_filter": 3.9, "interval_km": 10000}'::jsonb,
 'USA', 'Sedan', 'FWD', 'Compact'),

('Toyota', 'RAV4', 2019, NULL,
 '[
   {"engine": "2.5L 4-Cyl", "displacement": 2.5, "horsepower": 203, "torque": 184, "fuel": "Regular"},
   {"engine": "2.5L Hybrid", "displacement": 2.5, "horsepower": 219, "torque": 163, "fuel": "Hybrid"}
 ]'::jsonb,
 '{"oil_type": "0W-20", "capacity_with_filter": 4.8, "capacity_without_filter": 4.4, "interval_km": 10000}'::jsonb,
 'USA', 'SUV', 'AWD', 'Compact SUV'),

-- Honda Models
('Honda', 'Accord', 2018, NULL,
 '[
   {"engine": "1.5L Turbo", "displacement": 1.5, "horsepower": 192, "torque": 192, "fuel": "Regular"},
   {"engine": "2.0L Turbo", "displacement": 2.0, "horsepower": 252, "torque": 273, "fuel": "Premium"}
 ]'::jsonb,
 '{"oil_type": "0W-20", "capacity_with_filter": 4.4, "capacity_without_filter": 4.0, "interval_km": 10000}'::jsonb,
 'USA', 'Sedan', 'FWD', 'Mid-size'),

('Honda', 'Civic', 2016, NULL,
 '[
   {"engine": "1.5L Turbo", "displacement": 1.5, "horsepower": 174, "torque": 162, "fuel": "Regular"},
   {"engine": "2.0L", "displacement": 2.0, "horsepower": 158, "torque": 138, "fuel": "Regular"}
 ]'::jsonb,
 '{"oil_type": "0W-20", "capacity_with_filter": 4.2, "capacity_without_filter": 3.9, "interval_km": 10000}'::jsonb,
 'USA', 'Sedan', 'FWD', 'Compact'),

('Honda', 'CR-V', 2017, NULL,
 '[
   {"engine": "1.5L Turbo", "displacement": 1.5, "horsepower": 190, "torque": 179, "fuel": "Regular"}
 ]'::jsonb,
 '{"oil_type": "0W-20", "capacity_with_filter": 4.2, "capacity_without_filter": 3.9, "interval_km": 10000}'::jsonb,
 'USA', 'SUV', 'AWD', 'Compact SUV'),

-- BMW Models
('BMW', '3 Series', 2019, NULL,
 '[
   {"engine": "2.0L TwinPower Turbo", "displacement": 2.0, "horsepower": 255, "torque": 295, "fuel": "Premium"},
   {"engine": "3.0L TwinPower Turbo", "displacement": 3.0, "horsepower": 382, "torque": 365, "fuel": "Premium"}
 ]'::jsonb,
 '{"oil_type": "0W-30", "capacity_with_filter": 5.2, "capacity_without_filter": 4.8, "interval_km": 15000}'::jsonb,
 'USA', 'Sedan', 'RWD', 'Luxury'),

('BMW', 'X3', 2018, NULL,
 '[
   {"engine": "2.0L TwinPower Turbo", "displacement": 2.0, "horsepower": 248, "torque": 258, "fuel": "Premium"}
 ]'::jsonb,
 '{"oil_type": "0W-30", "capacity_with_filter": 5.2, "capacity_without_filter": 4.8, "interval_km": 15000}'::jsonb,
 'USA', 'SUV', 'AWD', 'Luxury SUV'),

-- Mercedes-Benz Models
('Mercedes-Benz', 'C-Class', 2019, NULL,
 '[
   {"engine": "2.0L Turbo", "displacement": 2.0, "horsepower": 255, "torque": 273, "fuel": "Premium"}
 ]'::jsonb,
 '{"oil_type": "0W-30", "capacity_with_filter": 6.0, "capacity_without_filter": 5.5, "interval_km": 12000}'::jsonb,
 'USA', 'Sedan', 'RWD', 'Luxury'),

('Mercedes-Benz', 'GLC', 2020, NULL,
 '[
   {"engine": "2.0L Turbo", "displacement": 2.0, "horsepower": 255, "torque": 273, "fuel": "Premium"}
 ]'::jsonb,
 '{"oil_type": "0W-30", "capacity_with_filter": 6.0, "capacity_without_filter": 5.5, "interval_km": 12000}'::jsonb,
 'USA', 'SUV', 'AWD', 'Luxury SUV'),

-- Nissan Models
('Nissan', 'Altima', 2019, NULL,
 '[
   {"engine": "2.5L 4-Cyl", "displacement": 2.5, "horsepower": 188, "torque": 180, "fuel": "Regular"}
 ]'::jsonb,
 '{"oil_type": "5W-30", "capacity_with_filter": 4.5, "capacity_without_filter": 4.2, "interval_km": 8000}'::jsonb,
 'USA', 'Sedan', 'FWD', 'Mid-size'),

('Nissan', 'Rogue', 2018, NULL,
 '[
   {"engine": "2.5L 4-Cyl", "displacement": 2.5, "horsepower": 170, "torque": 175, "fuel": "Regular"}
 ]'::jsonb,
 '{"oil_type": "5W-30", "capacity_with_filter": 4.9, "capacity_without_filter": 4.5, "interval_km": 8000}'::jsonb,
 'USA', 'SUV', 'AWD', 'Compact SUV'),

-- Hyundai Models
('Hyundai', 'Elantra', 2020, NULL,
 '[
   {"engine": "2.0L 4-Cyl", "displacement": 2.0, "horsepower": 147, "torque": 132, "fuel": "Regular"}
 ]'::jsonb,
 '{"oil_type": "5W-30", "capacity_with_filter": 4.2, "capacity_without_filter": 3.8, "interval_km": 8000}'::jsonb,
 'USA', 'Sedan', 'FWD', 'Compact'),

('Hyundai', 'Sonata', 2020, NULL,
 '[
   {"engine": "2.5L 4-Cyl", "displacement": 2.5, "horsepower": 191, "torque": 181, "fuel": "Regular"},
   {"engine": "1.6L Turbo", "displacement": 1.6, "horsepower": 180, "torque": 195, "fuel": "Regular"}
 ]'::jsonb,
 '{"oil_type": "5W-30", "capacity_with_filter": 4.4, "capacity_without_filter": 4.0, "interval_km": 8000}'::jsonb,
 'USA', 'Sedan', 'FWD', 'Mid-size'),

-- Kia Models
('Kia', 'Forte', 2019, NULL,
 '[
   {"engine": "2.0L 4-Cyl", "displacement": 2.0, "horsepower": 147, "torque": 132, "fuel": "Regular"}
 ]'::jsonb,
 '{"oil_type": "5W-30", "capacity_with_filter": 4.2, "capacity_without_filter": 3.8, "interval_km": 8000}'::jsonb,
 'USA', 'Sedan', 'FWD', 'Compact'),

('Kia', 'Sorento', 2021, NULL,
 '[
   {"engine": "2.5L 4-Cyl", "displacement": 2.5, "horsepower": 191, "torque": 182, "fuel": "Regular"},
   {"engine": "1.6L Turbo", "displacement": 1.6, "horsepower": 227, "torque": 258, "fuel": "Regular"}
 ]'::jsonb,
 '{"oil_type": "5W-30", "capacity_with_filter": 5.1, "capacity_without_filter": 4.7, "interval_km": 8000}'::jsonb,
 'USA', 'SUV', 'AWD', 'Mid-size SUV');

-- Insert comprehensive oil products
INSERT INTO oil_products (brand, product_name, oil_type, viscosity, specification, is_synthetic, is_semi_synthetic, is_conventional, price_per_liter, currency, availability_regions, compatible_vehicles, performance_features) VALUES
-- Mobil 1 Products
('Mobil 1', 'Advanced Fuel Economy', '0W-20', 'SAE 0W-20', 'API SP, ILSAC GF-6A', true, false, false, 8.50, 'USD', 
 '{"USA", "Canada", "Middle East"}', 
 '["Toyota", "Honda", "Nissan", "Hyundai", "Kia"]'::jsonb,
 '{"Advanced fuel economy", "Outstanding wear protection", "Excellent low-temperature flow"}'),

('Mobil 1', 'Full Synthetic', '0W-30', 'SAE 0W-30', 'API SP, BMW LL-01 FE', true, false, false, 9.00, 'USD',
 '{"USA", "Europe", "Middle East"}',
 '["BMW", "Mercedes-Benz", "Audi", "Volkswagen"]'::jsonb,
 '{"Superior engine protection", "Extended drain intervals", "High-temperature stability"}'),

('Mobil 1', 'High Mileage', '5W-30', 'SAE 5W-30', 'API SP, ILSAC GF-6A', true, false, false, 7.50, 'USD',
 '{"USA", "Canada"}',
 '["Toyota", "Honda", "Nissan", "Ford", "Chevrolet"]'::jsonb,
 '{"Reduces leaks", "Minimizes oil burn-off", "Conditions seals"}'),

-- Castrol Products
('Castrol', 'GTX High Mileage', '5W-30', 'SAE 5W-30', 'API SP, ILSAC GF-6A', false, true, false, 6.00, 'USD',
 '{"USA", "Canada", "Middle East"}',
 '["Toyota", "Honda", "Nissan", "Ford", "Chevrolet"]'::jsonb,
 '{"Seal conditioners", "Reduces oil consumption", "Superior wear protection"}'),

('Castrol', 'Edge', '0W-20', 'SAE 0W-20', 'API SP, ILSAC GF-6A', true, false, false, 8.00, 'USD',
 '{"USA", "Europe", "Asia"}',
 '["Toyota", "Honda", "Lexus", "Acura"]'::jsonb,
 '{"Titanium technology", "Reduces friction", "Superior performance"}'),

('Castrol', 'Edge Professional', '0W-30', 'SAE 0W-30', 'BMW LL-01 FE, MB 229.71', true, false, false, 10.00, 'USD',
 '{"Europe", "USA", "Middle East"}',
 '["BMW", "Mercedes-Benz"]'::jsonb,
 '{"OEM approved", "Extended service intervals", "Ultimate performance"}'),

-- Valvoline Products
('Valvoline', 'MaxLife', '5W-30', 'SAE 5W-30', 'API SP, ILSAC GF-6A', false, true, false, 5.50, 'USD',
 '{"USA", "Canada"}',
 '["Toyota", "Honda", "Nissan", "Ford", "Chevrolet", "Dodge"]'::jsonb,
 '{"Prevents leaks", "Reduces oil consumption", "Restores engine performance"}'),

('Valvoline', 'Advanced Full Synthetic', '0W-20', 'SAE 0W-20', 'API SP, ILSAC GF-6A', true, false, false, 7.00, 'USD',
 '{"USA", "Canada", "Middle East"}',
 '["Toyota", "Honda", "Nissan", "Hyundai", "Kia"]'::jsonb,
 '{"Superior protection", "Cleaner engines", "Enhanced fuel economy"}'),

-- Shell Products
('Shell', 'Helix Ultra', '0W-30', 'SAE 0W-30', 'BMW LL-01 FE, MB 229.71', true, false, false, 9.50, 'USD',
 '{"Europe", "Middle East", "Asia"}',
 '["BMW", "Mercedes-Benz", "Audi", "Volkswagen"]'::jsonb,
 '{"PurePlus technology", "Superior cleanliness", "Enhanced performance"}'),

('Shell', 'Rotella T6', '5W-40', 'SAE 5W-40', 'API CK-4, CJ-4', true, false, false, 6.50, 'USD',
 '{"USA", "Canada"}',
 '["Ford Diesel", "Chevrolet Diesel", "Ram Diesel"]'::jsonb,
 '{"Heavy-duty protection", "Excellent oxidation resistance", "Superior wear protection"}'),

-- Toyota Genuine Products
('Toyota', 'Genuine Motor Oil', '0W-20', 'SAE 0W-20', 'API SP, Toyota approved', true, false, false, 6.00, 'USD',
 '{"USA", "Canada", "Middle East", "Asia"}',
 '["Toyota", "Lexus"]'::jsonb,
 '{"OEM specification", "Optimized for Toyota engines", "Warranty protection"}'),

('Toyota', 'Genuine Motor Oil', '5W-30', 'SAE 5W-30', 'API SP, Toyota approved', false, true, false, 5.00, 'USD',
 '{"USA", "Canada", "Middle East", "Asia"}',
 '["Toyota", "Lexus"]'::jsonb,
 '{"OEM specification", "Proven performance", "Warranty protection"}'),

-- Honda Genuine Products
('Honda', 'Genuine Motor Oil', '0W-20', 'SAE 0W-20', 'API SP, Honda HTO-06', true, false, false, 6.50, 'USD',
 '{"USA", "Canada", "Asia"}',
 '["Honda", "Acura"]'::jsonb,
 '{"OEM specification", "Optimized for Honda engines", "Extended protection"}'),

-- BMW Genuine Products
('BMW', 'TwinPower Turbo Oil', '0W-30', 'SAE 0W-30', 'BMW LL-01 FE', true, false, false, 12.00, 'USD',
 '{"Europe", "USA", "Middle East"}',
 '["BMW"]'::jsonb,
 '{"Factory specification", "Optimized for TwinPower Turbo", "Maximum performance"}'),

-- Mercedes-Benz Genuine Products
('Mercedes-Benz', 'Genuine Engine Oil', '0W-30', 'SAE 0W-30', 'MB 229.71', true, false, false, 11.00, 'USD',
 '{"Europe", "USA", "Middle East"}',
 '["Mercedes-Benz"]'::jsonb,
 '{"Factory specification", "Advanced protection", "Optimal performance"});

-- Insert service centers
INSERT INTO service_centers (name, address, city, country, phone, email, specializations, services_offered, operating_hours, rating, is_certified) VALUES
('Quick Lube Express', '123 Main Street', 'New York', 'USA', '+1-555-0123', 'info@quicklube.com',
 '{"General Service", "All Makes"}', '{"Oil Change", "Filter Replacement", "Fluid Check"}',
 '{"monday": "08:00-18:00", "tuesday": "08:00-18:00", "wednesday": "08:00-18:00", "thursday": "08:00-18:00", "friday": "08:00-18:00", "saturday": "09:00-17:00", "sunday": "10:00-16:00"}'::jsonb,
 4.2, true),

('BMW Service Center', '456 Auto Drive', 'Los Angeles', 'USA', '+1-555-0456', 'service@bmwla.com',
 '{"BMW", "MINI"}', '{"Oil Change", "Complete Service", "Warranty Repairs", "Diagnostics"}',
 '{"monday": "07:00-19:00", "tuesday": "07:00-19:00", "wednesday": "07:00-19:00", "thursday": "07:00-19:00", "friday": "07:00-19:00", "saturday": "08:00-17:00", "sunday": "Closed"}'::jsonb,
 4.8, true),

('Mercedes-Benz Service', '789 Luxury Lane', 'Miami', 'USA', '+1-555-0789', 'service@mbmiami.com',
 '{"Mercedes-Benz", "Maybach", "AMG"}', '{"Oil Change", "Complete Service", "Warranty Repairs", "Performance Tuning"}',
 '{"monday": "07:00-18:00", "tuesday": "07:00-18:00", "wednesday": "07:00-18:00", "thursday": "07:00-18:00", "friday": "07:00-18:00", "saturday": "08:00-16:00", "sunday": "Closed"}'::jsonb,
 4.7, true),

('Toyota Service Plus', '321 Economy Road', 'Chicago', 'USA', '+1-555-0321', 'service@toyotaplus.com',
 '{"Toyota", "Lexus", "Scion"}', '{"Oil Change", "Maintenance", "Repairs", "Parts"}',
 '{"monday": "06:00-20:00", "tuesday": "06:00-20:00", "wednesday": "06:00-20:00", "thursday": "06:00-20:00", "friday": "06:00-20:00", "saturday": "07:00-19:00", "sunday": "08:00-18:00"}'::jsonb,
 4.5, true),

('Honda Care Center', '654 Reliable Street', 'Houston', 'USA', '+1-555-0654', 'care@hondahouston.com',
 '{"Honda", "Acura"}', '{"Oil Change", "Scheduled Maintenance", "Repairs", "Genuine Parts"}',
 '{"monday": "06:30-19:00", "tuesday": "06:30-19:00", "wednesday": "06:30-19:00", "thursday": "06:30-19:00", "friday": "06:30-19:00", "saturday": "07:00-18:00", "sunday": "09:00-17:00"}'::jsonb,
 4.6, true);

-- Insert sample maintenance records
INSERT INTO maintenance_records (vehicle_id, vin, service_type, service_date, mileage_at_service, oil_type_used, oil_quantity, filter_used, service_location, cost, currency, notes, additional_data) VALUES
-- This would need actual vehicle IDs from the vehicles table
-- These are example records with placeholder vehicle IDs
('00000000-0000-0000-0000-000000000001', 'SAMPLE123456789AB', 'Oil Change', '2024-01-15', 25000, '0W-20', 4.4, 'Toyota OEM Filter', 'Toyota Service Plus', 75.00, 'USD', 'Regular maintenance service', '{"technician": "John Smith", "service_advisor": "Mary Johnson"}'::jsonb),
('00000000-0000-0000-0000-000000000002', 'SAMPLE123456789CD', 'Oil Change', '2024-02-20', 30000, '0W-30', 5.2, 'BMW OEM Filter', 'BMW Service Center', 120.00, 'USD', 'Scheduled maintenance', '{"technician": "Mike Wilson", "next_service": "2024-08-20"}'::jsonb),
('00000000-0000-0000-0000-000000000003', 'SAMPLE123456789EF', 'Oil Change', '2024-03-10', 18000, '5W-30', 4.5, 'Nissan OEM Filter', 'Quick Lube Express', 45.00, 'USD', 'Quick service', '{"promotion": "Spring Special", "discount": 10.00}'::jsonb);