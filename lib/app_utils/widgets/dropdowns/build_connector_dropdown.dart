part of app_utils.widgets.dropdowns;

class BuildConnectorDropdown extends StatelessWidget {
  final String? title, mandatory, placeholder, errorText;
  final List? listData;
  final dynamic initialValue;
  final void Function(S2SingleSelected<String?>)? onChange;

  const BuildConnectorDropdown({
    Key? key,
    this.title,
    this.mandatory = '0',
    this.placeholder = 'select',
    this.errorText = '',
    this.listData,
    this.initialValue,
    this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.fromBorderSide(
                BorderSide(
                  width: 1.5,
                  style: BorderStyle.solid,
                  color: padQuotes(errorText).isNotEmpty
                      ? Colors.redAccent
                      : AppTheme.primaryColor,
                ),
              ),
            ),
            child: SmartSelect<String>.single(
              // placeholder: placeholder ?? "Select",
              title: '$title',
              selectedValue: initialValue,
              choiceType: S2ChoiceType.radios,
              choiceLayout: S2ChoiceLayout.list,
              modalConfig: S2ModalConfig(
                type: S2ModalType.popupDialog,
              ),
              tileBuilder:
                  (BuildContext context, S2SingleState<String?> s2SingleState) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    s2SingleState.showModal();
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            title!,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          Icon(
                        Icons.keyboard_arrow_down,
                        size: 20.sp,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                          Text(
                            padQuotes(s2SingleState.selected!.title).isNotEmpty
                                ? '${s2SingleState.selected!.title}'
                                : placeholder!,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                      // trailing: Icon(
                      //   Icons.keyboard_arrow_down,
                      //   size: 20.sp,
                      //   color: Theme.of(context).textTheme.bodyText1!.color,
                      // ),
                    ),
                  ),
                );
              },
              choiceItems: List.generate(
                listData!.length,
                (index) => S2Choice<String>(
                  value: listData![index]['connector_id'].toString(),
                  title: listData![index]['connector_id'].toString(),
                  style: S2ChoiceStyle(
                    titleStyle: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
              ),
              onChange: onChange,
            ),
          ),
          if (padQuotes(errorText).isNotEmpty)
            Container(
              padding: EdgeInsets.only(top: 5.0),
              width: double.infinity,
              child: Text(
                '$errorText',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
