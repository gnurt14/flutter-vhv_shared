part of '../../form.dart';

class FormTag extends FormWrapper<String> {
  final List? listSearch;

  const FormTag(
      {super.key, super.decoration, super.value, super.onChanged, this.listSearch});
  @override
  State<FormTag> createState() => _FormTagState();
}

class _FormTagState extends State<FormTag> {
  String _selectedValuesJson = '';
  List<Tag> _selectedTag = [];
  //TagService
  /// Mocks fetching Tag from network API with delay of 500ms.
  Future<List<Tag>> getTags(String query) async {
    await Future.delayed(const Duration(milliseconds: 500), null);
    return (widget.listSearch != null)
        ? widget.listSearch!.map((e) {
      return Tag(e);
    }).toList()
        : <Tag>[]
        .where(
            (tag) => tag.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
  @override
  void initState() {
    super.initState();
    _selectedTag = [];
    if (widget.value != null){
      _selectedTag = (widget.value)!.split(',').map((e) {
        return Tag(e);
      }).toList();
    }

  }
  @override
  void didUpdateWidget(covariant FormTag oldWidget) {
    if( widget.value != null){
      if (widget.value != oldWidget.value) {
        _selectedValuesJson = widget.value!;
      }
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  void dispose() {
    _selectedTag.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterTagging<Tag>(
      initialItems: _selectedTag,
      builder: (context, textEditController, focusNode){
        return TextField(
          controller: textEditController,
          focusNode: focusNode,
          decoration: widget.inputDecoration(context).copyWith(
            hintText: widget.inputDecoration(context).hintText ?? 'Search Tags',
            labelText: widget.inputDecoration(context).labelText ?? 'Select Tags',
          ),
        );
      },
      findSuggestions: getTags,
      additionCallback: (value) {
        return Tag(value);
      },
      onAdded: (tag) {
        // api calls here, triggered when add to tag button is pressed
        return tag;
      },
      configureSuggestion: (lang) {
        return SuggestionConfiguration(
          title: Text(lang.name),
          additionWidget: const Chip(
            avatar: Icon(
              Icons.add_circle,
              color: Colors.white,
            ),
            label: Text('Add New Tag'),
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
            ),
            backgroundColor: Colors.green,
          ),
        );
      },
      configureChip: (lang) {
        return ChipConfiguration(
          label: Text(lang.name),
          backgroundColor: Colors.green,
          labelStyle: const TextStyle(color: Colors.white),
          deleteIconColor: Colors.white,
        );
      },
      onChanged: () {
        setState(() {
          _selectedValuesJson = _selectedTag
              .map<String>((lang) => lang.toJson())
              .join(',');
        });
        if (widget.onChanged != null) {
          widget.onChanged!(_selectedValuesJson);
        }
      },
    );
  }
}

/// Tag Class
class Tag extends Taggable {
  ///
  final String name;

  ///
  /// Creates Language
  const Tag(
    this.name,
  );

  @override
  List<Object> get props => [name];

  /// Converts the class to json string.
  String toJson() => name;
}
