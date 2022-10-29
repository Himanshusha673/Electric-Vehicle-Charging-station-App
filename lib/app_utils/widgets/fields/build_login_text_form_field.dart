part of app_utils.widget.fields;

class BuildLoginTextFormField extends StatelessWidget {
  final String? title, hintText, mandatory, errorText;
  final TextEditingController controller;
  final bool? enabled, obscureText;
  final int? minLines, maxLines, maxLength;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final Color? borderColor;

  const BuildLoginTextFormField({
    Key? key,
    this.title,
    this.hintText,
    this.mandatory = '0',
    this.errorText = '',
    required this.controller,
    this.enabled,
    this.obscureText,
    this.minLines,
    this.maxLines = 1,
    this.maxLength = 255,
    this.keyboardType,
    this.suffixIcon,
    this.onChanged,
    this.borderColor,
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
              border: Border(
                bottom: BorderSide(
                  width: 1.5,
                  style: BorderStyle.solid,
                  color: (padQuotes(errorText).isNotEmpty)
                      ? Colors.redAccent
                      : (borderColor != null)
                          ? borderColor!
                          : Colors.grey,
                ),
              ),
            ),
            child: TextFormField(
              textAlign: TextAlign.center,
              enabled: enabled,
              controller: controller,
              obscureText: obscureText ?? false,
              maxLines: maxLines,
              minLines: minLines,
              maxLength: maxLength,
              keyboardType: keyboardType,
              onChanged: onChanged,
              inputFormatters: const [
                /*if (keyboardType == TextInputType.emailAddress)
                  LowerCaseTextInputFormatter(),*/
              ],
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.0.sp,
                  ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: const Color(0xff252a34).withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0.sp,
                    ),
                isDense: true,
                border: InputBorder.none,
                counterText: '',
                suffixIcon: suffixIcon,
              ),
            ),
          ),
          if (padQuotes(errorText).isNotEmpty)
            Container(
              padding: EdgeInsets.only(top: 5.0),
              alignment: Alignment.center,
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
