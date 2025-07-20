import 'package:codiaq_editor/src/buffer/buffer.dart';
import 'package:codiaq_editor/src/icons/seti.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_tabbar/reorderable_tabbar.dart';

class TabBarWidget extends StatefulWidget {
  final List<Buffer> tabs;
  final Function(int tabId)? onTabSelected;
  final Function(int tabId)? onTabClosed;
  final Function(int oldIndex, int newIndex) onTabReordered;
  final int activeTabIndex;
  const TabBarWidget({
    super.key,
    required this.tabs,
    required this.onTabReordered,
    required this.onTabClosed,
    this.onTabSelected,
    this.activeTabIndex = 0,
  });

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: widget.tabs.length, vsync: this);
    super.initState();
  }

  didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure the TabController is updated if the tabs change
    if (_tabController.length != widget.tabs.length) {
      _tabController.dispose();
      _tabController = TabController(length: widget.tabs.length, vsync: this);
      print("TabController initialized with ${widget.tabs.length} tabs");
    }

    if (_tabController.index != widget.activeTabIndex) {
      _tabController.index = widget.activeTabIndex;
    }
  }

  @override
  void didUpdateWidget(covariant TabBarWidget oldWidget) {
    if (_tabController.length != widget.tabs.length) {
      _tabController.dispose();
      _tabController = TabController(length: widget.tabs.length, vsync: this);
      print("TabController updated: ${widget.tabs.length} tabs");
    }

    if (_tabController.index != widget.activeTabIndex) {
      _tabController.index = widget.activeTabIndex;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 30,
          width: constraints.maxWidth,
          child: TabBarTheme(
            data: TabBarThemeData(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              indicatorColor: Colors.blue,
            ),
            child: ReorderableTabBar(
              labelPadding: EdgeInsets.symmetric(horizontal: 4),
              buildDefaultDragHandles: false,
              onReorder: widget.onTabReordered,
              controller: _tabController,
              isScrollable: true,
              indicatorWeight: 4,
              tabs:
                  widget.tabs.map((tab) {
                    return Tab(
                      key: Key(tab.id.toString()),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          getSetiIcon(tab.path.split('/').last, size: 20),
                          Text(tab.path.split('/').last, style: TextStyle()),
                          if (widget.tabs.length > 1)
                            IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (widget.onTabClosed != null) {
                                  var index = widget.tabs.indexOf(tab);
                                  widget.onTabClosed!(index);
                                }
                              },
                              icon: Icon(Icons.close, size: 16),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
              onTap: (index) {
                if (widget.onTabSelected != null) {
                  widget.onTabSelected!(index);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
