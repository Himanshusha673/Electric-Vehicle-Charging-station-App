part of app_utils.widgets.dropdowns;

class BuildDropdown extends StatelessWidget {
  final String? title, mandatory, placeholder, errorText;
  final List? listData;
  final dynamic initialValue;
  final ValueChanged<S2SingleSelected<String?>>? onChange;

  const BuildDropdown({
    Key? key,
    this.title,
    this.mandatory = '0',
    this.placeholder,
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
          if (padQuotes(title).isNotEmpty)
            Container(
              padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    padQuotes(title),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  if (mandatory == '1')
                    Padding(
                      padding: EdgeInsets.only(left: 2.0),
                      child: Text(
                        '*',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Colors.redAccent,
                            ),
                      ),
                    ),
                  Text(
                    ':',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            ),
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
              placeholder: placeholder ?? 'Select',
              title: '$title',
              selectedValue: initialValue,
              choiceType: S2ChoiceType.radios,
              choiceLayout: S2ChoiceLayout.list,
              choiceItems: List.generate(
                listData!.length,
                (index) => S2Choice<String>(
                  value: listData![index]['id'].toString(),
                  title: listData![index]['name'].toString(),
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
                ),
              ),
            ),
        ],
      ),
    );
  }
}
