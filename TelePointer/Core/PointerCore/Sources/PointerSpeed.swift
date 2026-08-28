func rampedSpeed(
    elapsed: Double,
    base: Double,
    peak: Double,
    rampDuration: Double,
    easing: SpeedEasing = .default
) -> Double {
    guard rampDuration > 0 else { return peak }

    let progress = min(max(elapsed / rampDuration, 0), 1)
    return base + (peak - base) * easing.value(at: progress)
}
