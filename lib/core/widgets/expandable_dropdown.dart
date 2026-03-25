import 'package:du_an/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

enum DropdownDirection { up, down }

class ExpandableDropdown extends StatefulWidget {
  final Widget title;
  final List<Widget> items;
  final DropdownDirection direction;

  const ExpandableDropdown({
    super.key,
    required this.title,
    required this.items,
    this.direction = DropdownDirection.down,
  });

  @override
  State<ExpandableDropdown> createState() => _ExpandableDropdownState();
}

class _ExpandableDropdownState extends State<ExpandableDropdown> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final dropdown = AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      crossFadeState:
      isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: _buildDropdown(),
      secondChild: const SizedBox(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.direction == DropdownDirection.down
          ? [_buildHeader(), dropdown]
          : [dropdown, _buildHeader()],
    );
  }

  Widget _buildHeader() {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor:  Colors.transparent,
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Row(
        children: [
          Expanded(child: widget.title),
          AnimatedRotation(
            turns: isExpanded
                ? (widget.direction == DropdownDirection.down ? 0.5 : -0.5)
                : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.keyboard_arrow_up_sharp,color: AppColors.primaryDark.withValues(alpha: 0.5), size: 20,),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.items.map((item) {
        return InkWell(
          splashColor: Colors.transparent,
          highlightColor:  Colors.transparent,
          onTap: () {
            setState(() {
              isExpanded = false;
            });
          },
          child: item,
        );
      }).toList(),
    );
  }
}
