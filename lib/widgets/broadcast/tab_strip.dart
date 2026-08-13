import 'package:flutter/material.dart';
import '../../theme/palette.dart';

class TabStripItem {
  final String label;
  final IconData icon;
  const TabStripItem({required this.label, required this.icon});
}

/// Underline tab strip — replaces the pill-shaped Material NavigationBar.
class BroadcastTabStrip extends StatelessWidget {
  final List<TabStripItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const BroadcastTabStrip({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.canvas,
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onSelect(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: i == currentIndex
                              ? p.brand
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          items[i].icon,
                          size: 21,
                          color: i == currentIndex ? p.brand : p.inkSoft,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[i].label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: i == currentIndex ? p.brand : p.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
