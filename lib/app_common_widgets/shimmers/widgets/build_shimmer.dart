part of common.shimmers.widgets;

class BuildShimmer extends StatelessWidget {
  final Widget child;

  const BuildShimmer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[350]!,
      highlightColor: Colors.grey[100]!,
      enabled: true,
      child: child,
    );
  }
}
