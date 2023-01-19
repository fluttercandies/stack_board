import 'package:flutter/painting.dart';
import 'package:stack_board/src/helpers/as_t.dart';
import 'package:stack_board/src/helpers/ex_enum.dart';

extension ExTextHeightBehavior on TextHeightBehavior {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'applyHeightToFirstAscent': applyHeightToFirstAscent,
      'applyHeightToLastDescent': applyHeightToLastDescent,
      'leadingDistribution': leadingDistribution.toString(),
    };
  }
}

TextHeightBehavior jsonToTextHeightBehavior(Map<String, dynamic> data) {
  return TextHeightBehavior(
    applyHeightToFirstAscent: asT<bool>(data['applyHeightToFirstAscent']),
    applyHeightToLastDescent: asT<bool>(data['applyHeightToLastDescent']),
    leadingDistribution: ExEnum.tryParse<TextLeadingDistribution>(
            TextLeadingDistribution.values, asT<String>(data['leadingDistribution'])) ??
        TextLeadingDistribution.proportional,
  );
}
