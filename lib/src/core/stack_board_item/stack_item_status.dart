/// * StackItemStatus
/// * [editing] editing
/// * [moving] moving
/// * [scaling] scaling
/// * [roating] roating
/// * [selected] selected
/// * [idle] idle
enum StackItemStatus {
  /// * 正在编辑
  /// * Editing
  editing,

  /// * 正在移动
  /// * Moving
  moving,

  /// * 正在缩放
  /// * Scaling
  scaling,

  /// * 正在旋转
  /// * Rotating
  roating,

  /// * 仅被选中
  /// * Selected
  selected,

  /// * 常规状态
  /// * Idle
  idle,
}
