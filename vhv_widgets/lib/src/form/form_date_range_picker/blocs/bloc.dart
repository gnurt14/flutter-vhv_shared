import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/src/form/form_date_range_picker/blocs/event.dart';
import 'package:vhv_widgets/src/form/form_date_range_picker/blocs/state.dart';

class DateRangeBloc extends Bloc<DateRangeEvent, DateRangeState> {
  DateRangeBloc([String initialValue = '']) : super(DateRangeState()) {
    on<DateRangeSet>(_onDateRangeSet);
    on<DateRangeReset>(_onDateRangeReset);

    if (initialValue.isNotEmpty) {
      _initializeFromValue(initialValue);
    }
  }

  void _onDateRangeSet(DateRangeSet event, Emitter<DateRangeState> emit) {
    emit(state.copyWith(
      startDate: event.start,
      endDate: event.end,
    ));
  }

  void _onDateRangeReset(DateRangeReset event, Emitter<DateRangeState> emit) {
    emit(DateRangeState());
  }

  void _initializeFromValue(String value) {
    final values = value.split('-');
    if (values.isNotEmpty) {
      if (values.length == 2) {
        add(DateRangeSet(
          start: _parseDateTime(values[0]),
          end: _parseDateTime(values[1]),
        ));
      } else if (values.length == 1) {
        final date = _parseDateTime(values[0]);
        add(DateRangeSet(start: date, end: date));
      }
    }
  }

  DateTime? _parseDateTime(String value) {
    try {
      return DateTime.parse(value.trim());
    } catch (e) {
      return null;
    }
  }
}