## 📋 Project Overview
This project analyzes Swiggy food delivery data to uncover business insights, customer trends, and performance metrics. The analysis helps understand ordering patterns, popular cuisines, and regional preferences to support data-driven decision making.

## 🗂️ Database Structure

### 📊 Fact Table
**fact_swiggy_orders** - Core transaction data including:
- Order details with pricing
- Customer ratings and feedback
- Relationships to all dimension tables

### 🗺️ Dimension Tables
- **dim_date** 📅 - Date intelligence for trend analysis
- **dim_location** 🗺️ - Geographic hierarchy (State → City → Location)
- **dim_restaurant** 🏪 - Restaurant master data
- **dim_category** 🍕 - Food category classification
- **dim_dish** 🍔 - Individual dish information

## 🔍 Key Business Insights

### 📈 Performance Metrics
- **Total Orders**: Measure overall platform activity
- **Revenue Analysis**: Track financial performance in millions
- **Customer Satisfaction**: Average ratings across all orders

### 🌍 Geographic Analysis
- **Top Cities**: Identify highest order volume locations
- **State Performance**: Compare regional contributions
- **Location Trends**: Understand local market preferences

### 🏪 Restaurant Performance
- **Top Restaurants**: Most ordered-from establishments
- **Category Popularity**: Which cuisines perform best
- **Price Point Analysis**: Customer spending patterns

### 📅 Temporal Trends
- **Monthly Patterns**: Seasonality and growth trends
- **Day of Week**: Peak ordering days (Mon-Sun analysis)
- **Time-based Strategies**: Optimize operations based on demand patterns

## 💡 Example Business Questions Answered

### 🎯 Customer Behavior
- *Which cities order the most food?* → Target marketing efforts
- *What price ranges are most popular?* → Optimize restaurant partnerships
- *Which days see peak orders?* → Improve delivery staffing

### 🚀 Growth Opportunities
- *Which categories are trending?* → Guide restaurant onboarding
- *How do ratings affect order volume?* → Quality improvement initiatives
- *Where are untapped markets?* → Expansion planning

## 🛠️ Technical Implementation

### 🔧 Data Pipeline
1. **Data Validation** ✅ - Check for nulls, blanks, and duplicates
2. **Schema Design** 🗃️ - Star schema for analytical efficiency
3. **ETL Process** 🔄 - Transform raw data into analytical format
4. **KPI Calculation** 📊 - Compute business metrics

### 📝 Key SQL Operations
- Data cleaning and deduplication
- Dimension table creation and population
- Fact table assembly with foreign key relationships
- Analytical queries for business intelligence

## 📊 Sample Insights Output
The analysis provides actionable insights such as:
- Peak ordering times and days
- Most profitable cities and regions
- Popular restaurant chains and categories
- Customer price sensitivity ranges
- Seasonal demand fluctuations

## 🎯 Business Impact
This analytics solution enables:
- **Strategic Planning**: Data-backed expansion decisions
- **Operational Efficiency**: Resource allocation optimization
- **Marketing Effectiveness**: Targeted promotional campaigns
- **Partner Success**: Helping restaurants maximize sales
