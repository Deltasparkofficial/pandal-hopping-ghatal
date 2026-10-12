import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/app_footer.dart';

class RestaurantItem {
  final String id;
  final String name;
  final String cuisine;
  final String nearestPandal;
  final String distance;
  final String walkTime;
  final double rating;
  final int reviewsCount;
  final String priceRange;
  final String badgeText;
  final Color badgeColor;
  final String mustTry;
  final String address;
  final String phone;
  final String category; // thali, sweets, rolls, biryani
  final List<MenuItem> menu;

  const RestaurantItem({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.nearestPandal,
    required this.distance,
    required this.walkTime,
    required this.rating,
    required this.reviewsCount,
    required this.priceRange,
    required this.badgeText,
    required this.badgeColor,
    required this.mustTry,
    required this.address,
    required this.phone,
    required this.category,
    required this.menu,
  });
}

class MenuItem {
  final String name;
  final String price;
  final bool isVeg;
  final bool isBestseller;

  const MenuItem({
    required this.name,
    required this.price,
    required this.isVeg,
    this.isBestseller = false,
  });
}

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Bengali Thali 🍛',
    'Mishti & Sweets 🍧',
    'Rolls & Snacks 🌯',
    'Biryani & Tandoor 🍗',
    'Late Night (Open 3 AM) 🌙',
  ];

  final List<RestaurantItem> _allRestaurants = [
    RestaurantItem(
      id: 'maa_tara',
      name: 'Maa Tara Hotel & Bengali Dining',
      cuisine: 'Traditional Bengali Meals & Fish Thali',
      nearestPandal: 'Ghatal Bazar Sarbojonin',
      distance: '0.2 km',
      walkTime: '3 min walk',
      rating: 4.7,
      reviewsCount: 380,
      priceRange: '₹120 - ₹240 / person',
      badgeText: 'Puja Special Thali Available',
      badgeColor: const Color(0xFFE65100),
      mustTry: 'Basanti Pulao with Kasha Mangsho & Ilish',
      address: 'Main Bazar Road, Opposite Old Clock Tower, Ghatal',
      phone: '+91 98321 44512',
      category: 'thali',
      menu: [
        MenuItem(name: 'Durga Puja Maha Thali', price: '₹220', isVeg: false, isBestseller: true),
        MenuItem(name: 'Katla Kalia with Steamed Rice', price: '₹140', isVeg: false, isBestseller: true),
        MenuItem(name: 'Basanti Pulao & Kosha Mangsho', price: '₹210', isVeg: false, isBestseller: true),
        MenuItem(name: 'Niramish Bhog Thali (Khichuri & Labra)', price: '₹110', isVeg: true),
        MenuItem(name: 'Mishti Doi & Chhanar Payesh', price: '₹40', isVeg: true),
      ],
    ),
    RestaurantItem(
      id: 'kushpata_mishti',
      name: 'Kushpata Mishti Hub & Sweets',
      cuisine: 'Heritage Bengali Sweets & Morning Luchi',
      nearestPandal: 'Kushpata Netaji Sangha',
      distance: '0.3 km',
      walkTime: '4 min walk',
      rating: 4.8,
      reviewsCount: 520,
      priceRange: '₹40 - ₹120 / person',
      badgeText: 'Famous Ghatal Chhana Sweets',
      badgeColor: const Color(0xFF2E7D32),
      mustTry: 'Hot Radhaballabhi & Chhanar Jilapi',
      address: 'Kushpata High School Crossing, Ghatal',
      phone: '+91 97334 89201',
      category: 'sweets',
      menu: [
        MenuItem(name: 'Radhaballabhi with Alur Dam (2 pcs)', price: '₹35', isVeg: true, isBestseller: true),
        MenuItem(name: 'Ghatal Special Chhanar Jilapi (2 pcs)', price: '₹30', isVeg: true, isBestseller: true),
        MenuItem(name: 'Kesar Baked Rosogolla (4 pcs)', price: '₹60', isVeg: true),
        MenuItem(name: 'Lyangcha of Shaktigarh style', price: '₹20', isVeg: true),
        MenuItem(name: 'Kaju Barfi & Sondesh Box', price: '₹180', isVeg: true),
      ],
    ),
    RestaurantItem(
      id: 'aahar_rolls',
      name: 'Aahar Fast Food & Kathi Roll Corner',
      cuisine: 'Kolkata Rolls, Chowmein & Mughlai Paratha',
      nearestPandal: 'Bidyasagar Setu Baroari',
      distance: '0.4 km',
      walkTime: '5 min walk',
      rating: 4.5,
      reviewsCount: 290,
      priceRange: '₹50 - ₹140 / person',
      badgeText: 'Open till 3:30 AM',
      badgeColor: const Color(0xFFB71C1C),
      mustTry: 'Double Egg Chicken Kathi Roll & Crispy Mughlai',
      address: 'Bidyasagar Bridge Approach, Shilabati Link Road',
      phone: '+91 94340 12890',
      category: 'rolls',
      menu: [
        MenuItem(name: 'Double Egg Chicken Roll', price: '₹80', isVeg: false, isBestseller: true),
        MenuItem(name: 'Paneer Cheese Tikka Roll', price: '₹70', isVeg: true),
        MenuItem(name: 'Egg Mughlai Paratha with Alur Kasha', price: '₹95', isVeg: false, isBestseller: true),
        MenuItem(name: 'Hakka Noodles with Chili Chicken', price: '₹130', isVeg: false),
        MenuItem(name: 'Crispy Veg Spring Roll (4 pcs)', price: '₹60', isVeg: true),
      ],
    ),
    RestaurantItem(
      id: 'subhasree_biryani',
      name: 'Subhasree Family Dining & Biryani Hub',
      cuisine: 'Kolkata Dum Biryani & Tandoori Kababs',
      nearestPandal: 'Konnagar Youth Club',
      distance: '0.6 km',
      walkTime: '7 min walk',
      rating: 4.6,
      reviewsCount: 410,
      priceRange: '₹150 - ₹320 / person',
      badgeText: 'Air Conditioned • Family Seating',
      badgeColor: const Color(0xFF1565C0),
      mustTry: 'Aromatic Kolkata Chicken Biryani with Aloo & Egg',
      address: 'Konnagar Bus Stand Square, Ghatal',
      phone: '+91 98322 77610',
      category: 'biryani',
      menu: [
        MenuItem(name: 'Special Kolkata Chicken Biryani', price: '₹170', isVeg: false, isBestseller: true),
        MenuItem(name: 'Mutton Dum Biryani (Kolkata Style)', price: '₹240', isVeg: false, isBestseller: true),
        MenuItem(name: 'Tandoori Chicken (Half)', price: '₹160', isVeg: false),
        MenuItem(name: 'Butter Naan with Chicken Chaap', price: '₹180', isVeg: false),
        MenuItem(name: 'Paneer Butter Masala with Rumali Roti', price: '₹140', isVeg: true),
      ],
    ),
    RestaurantItem(
      id: 'kharar_ghee_luchi',
      name: 'Kharar Heritage Ghee & Luchi Corner',
      cuisine: 'Desi Ghee Luchi, Hing Kachori & Chholar Dal',
      nearestPandal: 'Kharar Rajbari Mandir',
      distance: '0.5 km',
      walkTime: '6 min walk',
      rating: 4.7,
      reviewsCount: 220,
      priceRange: '₹40 - ₹100 / person',
      badgeText: '100% Pure Desi Ghee Prep',
      badgeColor: const Color(0xFFD4A017),
      mustTry: 'Ghee Luchi with Narkel Diye Chholar Dal',
      address: 'Near Old Brass Metal Market, Kharar Bazaar',
      phone: '+91 97321 00451',
      category: 'sweets',
      menu: [
        MenuItem(name: 'Desi Ghee Luchi with Chholar Dal (4 pcs)', price: '₹50', isVeg: true, isBestseller: true),
        MenuItem(name: 'Kachori with Dum Aloo & Chutney', price: '₹35', isVeg: true),
        MenuItem(name: 'Malpoa dipped in Cardamom Syrup (2 pcs)', price: '₹30', isVeg: true, isBestseller: true),
        MenuItem(name: 'Gulab Jamun with Rabri', price: '₹40', isVeg: true),
        MenuItem(name: 'Masala Cha in Clay Cup (Kullhad)', price: '₹15', isVeg: true),
      ],
    ),
    RestaurantItem(
      id: 'shilabati_river_cafe',
      name: 'Shilabati Riverside Cafe & Tea Bar',
      cuisine: 'Riverfront Chai, Singara, Jhalmuri & Quick Bites',
      nearestPandal: 'Bidyasagar Setu Baroari',
      distance: '0.3 km',
      walkTime: '4 min walk',
      rating: 4.6,
      reviewsCount: 190,
      priceRange: '₹30 - ₹90 / person',
      badgeText: 'River View Seating • Open All Night',
      badgeColor: const Color(0xFF6A1B9A),
      mustTry: 'River Breeze Special Kullhad Chai & Hot Singara',
      address: 'Ghat Stairs Promanade, Shilabati Riverbank, Ghatal',
      phone: '+91 98001 33499',
      category: 'rolls',
      menu: [
        MenuItem(name: 'Ginger Cardamom Kullhad Chai', price: '₹15', isVeg: true, isBestseller: true),
        MenuItem(name: 'Crispy Singara (Samosa) with Chutney (2 pcs)', price: '₹20', isVeg: true, isBestseller: true),
        MenuItem(name: 'Special Ghatal Jhalmuri with Mustard Oil', price: '₹25', isVeg: true),
        MenuItem(name: 'Cold Coffee with Chocolate Drizzle', price: '₹60', isVeg: true),
        MenuItem(name: 'Cheese Maggi with Herbs', price: '₹50', isVeg: true),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter list
    final filtered = _allRestaurants.where((r) {
      // Category filter
      if (_selectedCategory == 'Bengali Thali 🍛' && r.category != 'thali') return false;
      if (_selectedCategory == 'Mishti & Sweets 🍧' && r.category != 'sweets') return false;
      if (_selectedCategory == 'Rolls & Snacks 🌯' && r.category != 'rolls') return false;
      if (_selectedCategory == 'Biryani & Tandoor 🍗' && r.category != 'biryani') return false;
      if (_selectedCategory == 'Late Night (Open 3 AM) 🌙' && !r.badgeText.contains('Night') && !r.badgeText.contains('3 AM') && !r.badgeText.contains('3:30 AM')) return false;

      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = r.name.toLowerCase().contains(q);
        final matchCuisine = r.cuisine.toLowerCase().contains(q);
        final matchPandal = r.nearestPandal.toLowerCase().contains(q);
        final matchDish = r.mustTry.toLowerCase().contains(q);
        return matchName || matchCuisine || matchPandal || matchDish;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar / Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.restaurant_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nearest Restaurants',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 11, color: AppColors.primary),
                                  const SizedBox(width: 2),
                                  Text(
                                    'PANDAL HOPPING FOOD & SWEETS • GHATAL',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Open Now',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Search Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search thali, biryani, chhana mishti, rolls...',
                          hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category Filter Pills
            SliverToBoxAdapter(
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final isSel = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? AppColors.primary : AppColors.border,
                            width: 1,
                          ),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Foodie Tip Banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFF3E0),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFCC80), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFE65100), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Night Hopping Tip: Kushpata & Ghatal Bazar stalls serve hot Radhaballabhi and Chhana sweets till 3:00 AM during Maha Saptami & Ashtami!',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFFE65100),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Restaurant Count Summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} Eateries Near Active Pandals',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.sort_rounded, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Sorted by Distance',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Restaurant Cards List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filtered[index];
                    return _buildRestaurantCard(item);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
            // Deltaspark Watermark Footer
            const SliverToBoxAdapter(
              child: AppFooter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(RestaurantItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Name + Rating + Distance
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.cuisine,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Rating Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: Colors.white),
                          const SizedBox(width: 2),
                          Text(
                            item.rating.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Nearest Pandal Reference Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.temple_hindu, size: 13, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Near: ${item.nearestPandal}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${item.distance} • ${item.walkTime})',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Must-try recommendation line
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              border: Border(
                top: BorderSide(color: AppColors.border, width: 0.4),
                bottom: BorderSide(color: AppColors.border, width: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, size: 14, color: Color(0xFFD4A017)),
                const SizedBox(width: 6),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textPrimary),
                      children: [
                        const TextSpan(
                          text: 'Must Try: ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: item.mustTry,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Bottom stats & action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                // Price range
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Avg. Price',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item.priceRange,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // View Menu button
                OutlinedButton(
                  onPressed: () => _openMenuSheet(item),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'View Menu',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),

                // Directions Button
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening Google Maps route to ${item.name}...'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions_rounded, size: 14),
                  label: Text(
                    'Directions',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openMenuSheet(RestaurantItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFDFBF7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          item.address,
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.phone_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    item.phone,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Durga Puja Special Menu',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...item.menu.map((m) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: m.isVeg ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: m.isVeg ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  m.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (m.isBestseller) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFE082),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'POPULAR',
                                      style: GoogleFonts.poppins(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFE65100),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        m.price,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
