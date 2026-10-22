import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'btm_nav_item.dart';
import 'menu.dart';

class ModernBottomNav extends StatefulWidget {
  final RxList<BottomBarItem> items;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const ModernBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<ModernBottomNav> createState() => _ModernBottomNavState();
}

class _ModernBottomNavState extends State<ModernBottomNav> {
  final List<GlobalKey> _itemKeys = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _itemKeys.addAll(List.generate(widget.items.length, (_) => GlobalKey()));
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
  }

  @override
  void didUpdateWidget(ModernBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollToActive();
    }
    if (oldWidget.items.length != widget.items.length) {
      _itemKeys.clear();
      _itemKeys.addAll(List.generate(widget.items.length, (_) => GlobalKey()));
    }
  }

  void _scrollToActive() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedIndex >= _itemKeys.length) return;
      final key = _itemKeys[widget.selectedIndex];
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    while (_itemKeys.length < widget.items.length) {
      _itemKeys.add(GlobalKey());
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 10, 18, 10 + bottomPad),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: const Offset(0, 8),
                  blurRadius: 32,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.items.length, (index) {
                  return BtmNavItem(
                    key: _itemKeys[index],
                    navBar: widget.items[index],
                    isActive: index == widget.selectedIndex,
                    onTap: () => widget.onItemSelected(index),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
