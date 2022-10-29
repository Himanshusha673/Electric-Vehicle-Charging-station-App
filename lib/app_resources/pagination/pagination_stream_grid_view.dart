part of pagination.pagination_stream;

class PaginationStreamGridView<T> extends StatefulWidget {
  final SliverGridDelegate? gridDelegate;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final List<T>? initialData;
  final Future Function(int pageIndex) pageFetch;
  final Widget Function(BuildContext context, int index, T data) itemBuilder;
  final Widget onEmpty;
  final Widget Function(dynamic) onError;
  final Widget onPageLoading;
  final Widget onLoading;

  const PaginationStreamGridView({
    Key? key,
    required this.gridDelegate,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.initialData,
    this.physics,
    required this.pageFetch,
    required this.itemBuilder,
    required this.onError,
    required this.onEmpty,
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
  PaginationStreamGridViewState<T> createState() =>
      PaginationStreamGridViewState<T>();
}

class PaginationStreamGridViewState<T>
    extends State<PaginationStreamGridView<T>> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  final StreamController _streamController = StreamController();
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
                /*if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                    !_isPageLoading &&
                    data.length < totalCount) {
                  _loadData();
                }*/
                return false;
              },
              child: GridView.builder(
                gridDelegate: widget.gridDelegate ??
                    SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 5.0,
                      crossAxisCount: (MediaQuery.of(context).orientation ==
                              Orientation.portrait)
                          ? 2
                          : 4,
                      childAspectRatio: 0.7,
                    ),
                shrinkWrap: widget.shrinkWrap,
                scrollDirection: widget.scrollDirection,
                physics: widget.physics,
                padding: widget.padding,
                itemCount: (_totalCount != -1) ? data.length + 1 : data.length,
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
    _streamController.close();
    super.dispose();
  }
}
