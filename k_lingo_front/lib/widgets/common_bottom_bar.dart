import 'package:flutter/material.dart';

class CommonBottomBar extends StatelessWidget {
  final int currentIndex;
  
  // 👇 [중요] 이 부분이 빠져있어서 에러가 난 겁니다! 추가해주세요.
  final Function(int) onTap; 

  const CommonBottomBar({
    super.key,
    required this.currentIndex,
    
    // 👇 [중요] 생성자에도 추가!
    required this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildItem(Icons.home_rounded, 'Home', 0),
            _buildItem(Icons.edit_note_rounded, 'Review', 1),
            _buildItem(Icons.search_rounded, 'Search', 2),
            _buildItem(Icons.bar_chart_rounded, 'Stats', 3),
            _buildItem(Icons.person_rounded, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, int index) {
    final bool isActive = currentIndex == index;
    final Color activeColor = const Color(0xFFA855F7);
    final Color inactiveColor = const Color(0xFF9CA3AF);

    return Expanded(
      child: InkWell(
        // 👇 클릭하면 부모(MainScreen)에게 알림
        onTap: () => onTap(index), 
        
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}