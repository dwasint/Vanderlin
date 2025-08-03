#define MAX_PLANT_HEALTH 100
#define MAX_PLANT_WATER 150
#define MAX_PLANT_NITROGEN 200  // N - for leafy growth
#define MAX_PLANT_PHOSPHORUS 150 // P - for root/flower development
#define MAX_PLANT_POTASSIUM 100  // K - for overall plant health
#define MAX_PLANT_WEEDS 100

// Plant growth timing constants
#define FAST_GROWING 5 MINUTES
#define VERY_FAST_GROWING 4 MINUTES
#define HUNGRINESS_DEMANDING 35
#define HUNGRINESS_NORMAL 25
#define HUNGRINESS_TINY 15

// Genetic trait definitions
#define TRAIT_YIELD 1
#define TRAIT_DISEASE_RESISTANCE 2
#define TRAIT_QUALITY 3
#define TRAIT_GROWTH_SPEED 4
#define TRAIT_WATER_EFFICIENCY 5
#define TRAIT_COLD_RESISTANCE 6

// Trait grades (0-100, higher is better)
#define TRAIT_GRADE_POOR 20
#define TRAIT_GRADE_AVERAGE 50
#define TRAIT_GRADE_GOOD 70
#define TRAIT_GRADE_EXCELLENT 90

// Mutation chances
#define BASE_MUTATION_CHANCE 1  // 1% base chance
#define STRESS_MUTATION_MULTIPLIER 3  // Stress increases mutations

// Plant family compatibility groups
#define FAMILY_BRASSICA 1      // Cabbage family
#define FAMILY_ALLIUM 2        // Onion family
#define FAMILY_GRAIN 3         // Wheat, oat
#define FAMILY_SOLANACEAE 4    // Nightshade family
#define FAMILY_ROSACEAE 5      // Rose family (apple, pear, berries)
#define FAMILY_RUTACEAE 6      // Citrus family
#define FAMILY_ASTERACEAE 7    // Sunflower family
#define FAMILY_HERB 8          // Alchemical herbs
#define FAMILY_ROOT 9          // Root vegetables
