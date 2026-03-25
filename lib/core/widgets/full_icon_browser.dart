import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';

class FullIconBrowser extends StatefulWidget {
  final Set<int> usedIcons;

  const FullIconBrowser({super.key, this.usedIcons = const {}});

  @override
  State<FullIconBrowser> createState() => _FullIconBrowserState();
}

class _FullIconBrowserState extends State<FullIconBrowser> {
  int _selectedGroup = 0;

  static const _iconGroups = <String, List<IconData>>{
    'Phổ biến': [
      Icons.star, Icons.favorite, Icons.home, Icons.work, Icons.flash_on,
      Icons.check_circle, Icons.flag, Icons.bookmark, Icons.thumb_up, Icons.emoji_events,
      Icons.diamond, Icons.rocket_launch, Icons.auto_awesome, Icons.lightbulb, Icons.psychology,
    ],
    'Ăn uống': [
      Icons.restaurant, Icons.coffee, Icons.local_cafe, Icons.local_bar, Icons.local_pizza,
      Icons.cake, Icons.icecream, Icons.lunch_dining, Icons.ramen_dining, Icons.local_dining,
      Icons.fastfood, Icons.bakery_dining, Icons.emoji_food_beverage, Icons.wine_bar, Icons.liquor,
    ],
    'Di chuyển': [
      Icons.directions_car, Icons.directions_bus, Icons.local_taxi, Icons.two_wheeler,
      Icons.flight, Icons.train, Icons.directions_bike, Icons.electric_car,
      Icons.local_gas_station, Icons.local_parking, Icons.navigation, Icons.map,
    ],
    'Mua sắm': [
      Icons.shopping_bag, Icons.shopping_cart, Icons.store, Icons.local_mall,
      Icons.checkroom, Icons.watch, Icons.phone_android, Icons.laptop, Icons.headphones,
      Icons.camera_alt, Icons.tv, Icons.chair, Icons.weekend, Icons.blender,
    ],
    'Giải trí': [
      Icons.movie, Icons.sports_esports, Icons.music_note, Icons.headset,
      Icons.theater_comedy, Icons.park, Icons.pool, Icons.beach_access,
      Icons.nightlife, Icons.celebration, Icons.palette, Icons.brush, Icons.piano,
    ],
    'Tài chính': [
      Icons.account_balance_wallet, Icons.savings, Icons.monetization_on,
      Icons.credit_card, Icons.account_balance, Icons.trending_up, Icons.trending_down,
      Icons.currency_exchange, Icons.paid, Icons.receipt, Icons.request_quote,
      Icons.real_estate_agent, Icons.money, Icons.attach_money, Icons.price_check,
    ],
    'Sức khỏe': [
      Icons.local_hospital, Icons.medication, Icons.healing, Icons.health_and_safety,
      Icons.fitness_center, Icons.self_improvement, Icons.spa, Icons.sports,
      Icons.medical_services, Icons.monitor_heart, Icons.vaccines, Icons.bloodtype,
    ],
    'Giáo dục': [
      Icons.school, Icons.menu_book, Icons.auto_stories, Icons.library_books,
      Icons.science, Icons.biotech, Icons.calculate, Icons.translate,
      Icons.history_edu, Icons.architecture, Icons.design_services, Icons.draw,
    ],
    'Nhà cửa': [
      Icons.home, Icons.bolt, Icons.water_drop, Icons.wifi, Icons.phone,
      Icons.cleaning_services, Icons.build, Icons.plumbing, Icons.roofing,
      Icons.yard, Icons.deck, Icons.garage, Icons.bed, Icons.bathtub,
    ],
    'Khác': [
      Icons.more_horiz, Icons.category, Icons.label, Icons.push_pin,
      Icons.pets, Icons.child_care, Icons.volunteer_activism, Icons.card_giftcard,
      Icons.subscriptions, Icons.loyalty, Icons.local_offer, Icons.toll,
      Icons.alarm, Icons.event, Icons.today, Icons.schedule,
    ],
  };

  List<String> get _groupNames => _iconGroups.keys.toList();

  @override
  Widget build(BuildContext context) {
    final groupName = _groupNames[_selectedGroup];
    final allIcons = _iconGroups[groupName] ?? [];
    // Hide used icons
    final icons = allIcons.where((i) => !widget.usedIcons.contains(i.codePoint)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn biểu tượng'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _groupNames.length,
              itemBuilder: (context, index) {
                final selected = _selectedGroup == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(_groupNames[index], style: TextStyle(fontSize: 12, color: selected ? Colors.white : null)),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    onSelected: (_) => setState(() => _selectedGroup = index),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final icon = icons[index];
          return GestureDetector(
            onTap: () => Navigator.pop(context, icon),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: Colors.grey.shade700),
            ),
          );
        },
      ),
    );
  }
}
