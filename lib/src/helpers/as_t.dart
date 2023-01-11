import 'dart:convert';

/// 转换为 Map<String, dynamic>
/// Convert to Map<String, dynamic>
Map<String, dynamic> asMap(dynamic value) {
  if (value == null) {
    return <String, dynamic>{};
  }
  return asT<Map<String, dynamic>>(value);
}

/// 自动转换类型
/// Auto convert type
T asT<T>(dynamic value, [T? def]) {
  if (value is T) {
    return value;
  }
  if (T == String) {
    return '' as T;
  }
  if (T == bool) {
    return false as T;
  }
  if (T == int) {
    return 0 as T;
  }
  if (T == double) {
    return 0.0 as T;
  }

  if (<String, String>{} is T) {
    if (value is String && value.isNotEmpty) {
      return json.decode(value) as T;
    }
    return <String, String>{} as T;
  }
  if (<String, dynamic>{} is T) {
    if (value is String) {
      return json.decode(value) as T;
    }
    return <String, dynamic>{} as T;
  }
  if (<dynamic, dynamic>{} is T) {
    if (value is String) {
      return json.decode(value) as T;
    }
    return <dynamic, dynamic>{} as T;
  }
  return def as T;
}

/// 自动转换为可空类型
/// Auto convert to nullable type
T? asNullT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}
