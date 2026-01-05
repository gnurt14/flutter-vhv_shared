part of '../../form.dart';

class FormRating extends StatefulWidget {
  const FormRating({super.key, this.icon, this.ratedIcon, this.value = 0,
    this.onChanged, this.color, this.ratedColor, this.enabled = true});
  final Widget? icon;
  final Widget? ratedIcon;
  final Color? color;
  final Color? ratedColor;
  final double value;
  final bool enabled;
  final ValueChanged<double>? onChanged;

  @override
  State<FormRating> createState() => _FormRatingState();
}

class _FormRatingState extends State<FormRating> {
  double value = 0;
  void _onChanged(double newValue){
    value = newValue;
    setState(() {

    });
    if(widget.onChanged != null)widget.onChanged!(value);
  }
  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FormRating oldWidget) {
    value = widget.value;
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index){
        return _icon(index + 1);
      }),
    );
  }
  Widget _icon(int index){
    return GestureDetector(
      onTap: widget.enabled?(){
        _onChanged(index * 1.0);
      }:null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconTheme(
          data: IconThemeData(
            color: (index <= value.ceil())?(widget.ratedColor??Colors.amber):(widget.color??Colors.amber.withValues(alpha: 0.7))
          ),
          child: (index <= value.ceil())
              ?(widget.ratedIcon??const Icon(ViIcons.star_solid))
              :(widget.icon??const Icon(ViIcons.star)),
        ),
      ),
    );
  }
}
