part of auth_card_builder;

class _RecoverCard extends StatefulWidget {
  const _RecoverCard({
    Key? key,
    required this.userValidator,
    required this.onBack,
    required this.userType,
    this.secondFieldType,
    this.loginTheme,
    required this.navigateBack,
    required this.onSubmitCompleted,
    required this.loadingController,
    this.secondFieldValidator,
  }) : super(key: key);

  final FormFieldValidator<String>? userValidator;
  final FormFieldValidator<String>? secondFieldValidator;
  final Function onBack;
  final LoginUserType userType;
  final LoginUserType? secondFieldType;
  final LoginTheme? loginTheme;
  final bool navigateBack;
  final AnimationController loadingController;

  final Function onSubmitCompleted;

  @override
  _RecoverCardState createState() => _RecoverCardState();
}

class _RecoverCardState extends State<_RecoverCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();

  bool _isSubmitting = false;

  late TextEditingController _nameController;
  TextEditingController? _secondFieldController;

  late AnimationController _submitController;

  bool _isRecoverWithTwoFields = false;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<Auth>(context, listen: false);

    final messages = Provider.of<LoginMessages>(context, listen: false);

    // If recoverPwUserHint is set, then the logic needs to be split
    _nameController = TextEditingController(
      text: messages.recoverPwUserHint == null ? auth.userName : '',
    );

    if (messages.secondRecoveryFieldHint != null) {
      _isRecoverWithTwoFields = true;
      _secondFieldController = TextEditingController(text: auth.userName);
    }

    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _submitController.dispose();
    super.dispose();
  }

  Future<bool> _submit() async {
    if (!_formRecoverKey.currentState!.validate()) {
      return false;
    }
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    _formRecoverKey.currentState!.save();
    await _submitController.forward();
    setState(() => _isSubmitting = true);
    final String? error;
    if (_isRecoverWithTwoFields) {
      error = await auth.onRecoverWithTwoFields!(
        RecoverDataTwoFields(
          mail: auth.secondRecoveryField,
          customerNumber: auth.userName,
        ),
      );
    } else {
      error = await auth.onRecoverPassword!(auth.userName);
    }
    if (error != null) {
      showErrorToast(context, messages.flushbarTitleError, error);
      setState(() => _isSubmitting = false);
      await _submitController.reverse();
      return false;
    } else {
      showSuccessToast(
        context,
        messages.flushbarTitleSuccess,
        messages.recoverPasswordSuccess,
      );
      setState(() => _isSubmitting = false);
      widget.onSubmitCompleted();
      return true;
    }
  }

  Widget _buildRecoverSecondField(
    double width,
    LoginMessages messages,
    Auth auth,
  ) {
    return AnimatedTextFormField(
      controller: _secondFieldController,
      loadingController: widget.loadingController,
      width: width,
      labelText: messages.secondRecoveryFieldHint,
      prefixIcon: const Icon(FontAwesomeIcons.solidCircleUser),
      keyboardType:
          widget.secondFieldType != null
              ? TextFieldUtils.getKeyboardType(widget.secondFieldType!)
              : null,
      autofillHints:
          widget.secondFieldType != null
              ? [TextFieldUtils.getAutofillHints(widget.secondFieldType!)]
              : null,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _submit(),
      validator: widget.secondFieldValidator,
      onSaved: (value) => auth.userName = value!,
    );
  }

  Widget _buildRecoverNameField(
    double width,
    LoginMessages messages,
    Auth auth,
  ) {
    return AnimatedTextFormField(
      controller:
          messages.recoverPwUserHint == null
              ? _nameController
              : TextEditingController(),
      loadingController: widget.loadingController,
      width: width,
      labelText: messages.recoverPwUserHint ?? messages.userHint,
      prefixIcon: const Icon(FontAwesomeIcons.solidCircleUser),
      keyboardType: TextFieldUtils.getKeyboardType(widget.userType),
      autofillHints: [TextFieldUtils.getAutofillHints(widget.userType)],
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _submit(),
      validator: widget.userValidator,
      onSaved: (name) => _onRecoverNameSaved(name!, messages, auth),
    );
  }

  Widget _buildRecoverButton(ThemeData theme, LoginMessages messages) {
    return AnimatedButton(
      controller: _submitController,
      text: messages.recoverPasswordButton,
      onPressed: !_isSubmitting ? _submit : null,
    );
  }

  Widget _buildBackButton(
    ThemeData theme,
    LoginMessages messages,
    LoginTheme? loginTheme,
  ) {
    final calculatedTextColor =
        (theme.cardTheme.color!.computeLuminance() < 0.5)
            ? Colors.white
            : theme.primaryColor;
    return MaterialButton(
      onPressed:
          !_isSubmitting
              ? () {
                _formRecoverKey.currentState!.save();
                widget.onBack();
              }
              : null,
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: loginTheme?.switchAuthTextColor ?? calculatedTextColor,
      child: Text(messages.goBackButton),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = min(deviceSize.width * 0.75, 360.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;

    return FittedBox(
      child: Card(
        child: Container(
          padding: const EdgeInsets.only(
            left: cardPadding,
            top: cardPadding + 10.0,
            right: cardPadding,
            bottom: cardPadding,
          ),
          width: cardWidth,
          alignment: Alignment.center,
          child: Form(
            key: _formRecoverKey,
            child: Column(
              children: [
                Text(
                  messages.recoverPasswordIntro,
                  key: kRecoverPasswordIntroKey,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                _buildRecoverNameField(textFieldWidth, messages, auth),
                if (_isRecoverWithTwoFields) const SizedBox(height: 20),
                if (_isRecoverWithTwoFields)
                  _buildRecoverSecondField(textFieldWidth, messages, auth),
                const SizedBox(height: 20),
                if (!_isRecoverWithTwoFields)
                  Text(
                    auth.onConfirmRecover != null
                        ? messages.recoverCodePasswordDescription
                        : messages.recoverPasswordDescription,
                    key: kRecoverPasswordDescriptionKey,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                const SizedBox(height: 26),
                _buildRecoverButton(theme, messages),
                _buildBackButton(theme, messages, widget.loginTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onRecoverNameSaved(String value, LoginMessages messages, Auth auth) {
    if (_isRecoverWithTwoFields) {
      auth.secondRecoveryField = value;
    } else if (messages.recoverPwUserHint == null) {
      auth.userName = value;
    }
  }
}
