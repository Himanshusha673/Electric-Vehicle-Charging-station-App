part of pagination.pagination_stream;

class PaginationStreamListView<T> extends StatefulWidget {
  final bool? shrinkWrap;
  final Axis scrollDirection;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final List<T>? initialData;
  final Future Function(int pageIndex) pageFetch;
  final Widget Function(BuildContext context, int index, T data) itemBuilder;
  final Widget Function(BuildContext, int index, T data) separatorBuilder;
  final Widget Function(dynamic) onError;
  final Widget onEmpty, onPageLoading, onLoading;

  const PaginationStreamListView({
    Key? key,
    this.shrinkWrap,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.physics,
    this.padding,
    this.initialData,
    required this.pageFetch,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.onEmpty,
    required this.onError,
    this.onPageLoading = const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(),
        ),
      ),
    ),
    this.onLoading = const Center(
      child: SizedBox(
        height: 25,
        width: 25,
        child: CircularProgressIndicator(),
      ),
    ),
  }) : super(key: key);

  @override
  PaginationStreamListViewState<T> createState() =>
      PaginationStreamListViewState<T>();
}

class PaginationStreamListViewState<T>
    extends State<PaginationStreamListView<T>> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  final StreamController _streamController = StreamController.broadcast();
  final List<dynamic> _itemList = <dynamic>[];
  bool _isPageLoading = false;
  int _pageIndex = 0;
  int _totalCount = -1;

  void _loadData() async {
    _isPageLoading = true;
    Map? res = await (widget.pageFetch(++_pageIndex)) as Map?;
    _isPageLoading = false;
    if (res != null) {
      _totalCount = numeric(res['total']);
      List data = res['data'];
      _itemList.addAll(data);
    }

    if (!_streamController.isClosed) {
      _streamController.sink.add(_itemList);
    }
  }

  void removeItem(int index) {
    _itemList.removeAt(index);
    _totalCount--;
    _streamController.sink.add(_itemList);
  }

  void refreshItem() {
    _itemList.clear();
    _pageIndex = 0;
    _totalCount = -1;
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _streamController.stream,
      initialData: widget.initialData,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          List data = snapshot.data;
          if (data.isNotEmpty) {
            return NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                return true;
              },
              child: ListView.separated(
                shrinkWrap: widget.shrinkWrap!,
                scrollDirection: widget.scrollDirection,
                controller: widget.controller,
                physics: widget.physics,
                padding: widget.padding,
                itemCount: (_totalCount != -1) ? data.length + 1 : data.length,
                addSemanticIndexes: true,
                itemBuilder: (BuildContext context, int index) {
                  /// end of list and has initialData
                  if (index == data.length && _totalCount == -1) {
                    return Container();
                  }

                  /// end of list
                  if (index == data.length && data.length == _totalCount) {
                    return Container();
                  }

                  /// load
                  if (index == data.length &&
                      data.length < _totalCount &&
                      _isPageLoading == false) {
                    _loadData();
                    return widget.onPageLoading;
                  }

                  /// data
                  return widget.itemBuilder(
                    context,
                    index,
                    data[index],
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  if (index == data.length - 1) {
                    return Container();
                  }
                  return widget.separatorBuilder(
                    context,
                    index,
                    data[index],
                  );
                },
              ),
            );
          } else {
            return widget.onEmpty;
          }
        } else {
          return widget.onLoading;
        }
      },
    );
  }

  @override
  void dispose() {
    // debugPrintDispose(widget.runtimeType);
    _streamController.close();
    super.dispose();
  }
}
