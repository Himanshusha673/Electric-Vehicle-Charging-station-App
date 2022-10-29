part of app_utils.widget.fields;

class BuildSignUpTextFormField extends StatelessWidget {
  final String? labelText, hintText, mandatory, errorText;
  final TextEditingController controller;
  final bool? enabled, obscureText;
  final int? minLines, maxLines, maxLength;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final Color? borderColor;

  const BuildSignUpTextFormField({
    Key? key,
    required this.labelText,
    required this.hintText,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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
        inputFormatters: [
          if (keyboardType == TextInputType.number)
            FilteringTextInputFormatter.digitsOnly,
        ],
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
        validator: (value) {
          if (errorText!.isNotEmpty) {
            return errorText;
          } else {
            return null;
          }
        },
        autovalidateMode: AutovalidateMode.always,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xff252a34).withOpacity(0.6),
              ),
          isDense: true,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.redAccent,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.redAccent,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          counterText: '',
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
