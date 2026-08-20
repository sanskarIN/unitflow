use unitflow_core::{
    BridgeBatchConversionRequest, BridgeConversionRequest, BridgeService, RoundMode,
    BRIDGE_BACKEND_ID, BRIDGE_CAPABILITIES, BRIDGE_CAPABILITY_BATCH_CONVERT,
    BRIDGE_CAPABILITY_CANONICAL_DECIMAL_TEXT, BRIDGE_CAPABILITY_CONVERT,
    BRIDGE_PROTOCOL_VERSION,
};

fn request(value: &str, from: &str, to: &str) -> BridgeConversionRequest {
    BridgeConversionRequest {
        value: value.to_owned(),
        from_unit_id: from.to_owned(),
        to_unit_id: to.to_owned(),
        decimal_places: None,
        round_mode: RoundMode::NearestEven,
    }
}

#[test]
fn exposes_stable_protocol_metadata() {
    let service = BridgeService::with_built_in_catalog().expect("built-in bridge service");
    assert_eq!(service.protocol_version(), BRIDGE_PROTOCOL_VERSION);
    assert_eq!(service.backend_id(), BRIDGE_BACKEND_ID);
    assert_eq!(BRIDGE_PROTOCOL_VERSION, 1);

    let info = service.info();
    assert_eq!(info.protocol_version, BRIDGE_PROTOCOL_VERSION);
    assert_eq!(info.backend_id, BRIDGE_BACKEND_ID);
    assert_eq!(
        info.capabilities,
        BRIDGE_CAPABILITIES
            .iter()
            .map(|capability| (*capability).to_owned())
            .collect::<Vec<_>>()
    );
    assert_eq!(
        BRIDGE_CAPABILITIES,
        [
            BRIDGE_CAPABILITY_CONVERT,
            BRIDGE_CAPABILITY_BATCH_CONVERT,
            BRIDGE_CAPABILITY_CANONICAL_DECIMAL_TEXT,
        ]
    );
}

#[test]
fn serializes_startup_metadata_with_camel_case_fields() {
    let service = BridgeService::with_built_in_catalog().expect("built-in bridge service");
    let encoded = serde_json::to_value(service.info()).expect("bridge info serializes");

    assert_eq!(encoded["protocolVersion"].as_u64(), Some(1));
    assert_eq!(encoded["backendId"].as_str(), Some("rust-core"));
    assert_eq!(
        encoded["capabilities"].as_array().map(Vec::len),
        Some(BRIDGE_CAPABILITIES.len())
    );
    assert!(encoded.get("protocol_version").is_none());
}

#[test]
fn converts_with_canonical_decimal_strings() {
    let service = BridgeService::with_built_in_catalog().expect("built-in bridge service");
    let result = service
        .convert(request("1.25", "meter", "centimeter"))
        .expect("conversion should succeed");

    assert_eq!(result.input, "1.25");
    assert_eq!(result.output, "125");
    assert_eq!(result.from_unit_id, "meter");
    assert_eq!(result.to_unit_id, "centimeter");
}

#[test]
fn rejects_non_canonical_decimal_text() {
    let service = BridgeService::with_built_in_catalog().expect("built-in bridge service");
    let failure = service
        .convert(request("1.0", "meter", "centimeter"))
        .expect_err("trailing-zero input must be rejected at the boundary");

    assert_eq!(failure.code, "invalid_decimal");
    assert!(!failure.message.contains("1.0"));
}

#[test]
fn maps_unknown_units_without_echoing_untrusted_identifiers() {
    let service = BridgeService::with_built_in_catalog().expect("built-in bridge service");
    let failure = service
        .convert(request("1", "not_a_real_unit", "meter"))
        .expect_err("unknown unit must fail");

    assert_eq!(failure.code, "unknown_unit");
    assert!(!failure.message.contains("not_a_real_unit"));
}

#[test]
fn maps_category_mismatch_and_invalid_precision() {
    let service = BridgeService::with_built_in_catalog().expect("built-in bridge service");

    let mismatch = service
        .convert(request("1", "meter", "kilogram"))
        .expect_err("cross-category conversion must fail");
    assert_eq!(mismatch.code, "category_mismatch");

    let mut invalid_precision = request("1", "meter", "centimeter");
    invalid_precision.decimal_places = Some(29);
    let failure = service
        .convert(invalid_precision)
        .expect_err("unsupported precision must fail");
    assert_eq!(failure.code, "invalid_precision");
}

#[test]
fn preserves_batch_target_order() {
    let service = BridgeService::with_built_in_catalog().expect("built-in bridge service");
    let results = service
        .batch_convert(BridgeBatchConversionRequest {
            value: "2".to_owned(),
            from_unit_id: "meter".to_owned(),
            target_unit_ids: vec!["centimeter".to_owned(), "millimeter".to_owned()],
            decimal_places: None,
            round_mode: RoundMode::NearestEven,
        })
        .expect("batch conversion should succeed");

    assert_eq!(results.len(), 2);
    assert_eq!(results[0].to_unit_id, "centimeter");
    assert_eq!(results[0].output, "200");
    assert_eq!(results[1].to_unit_id, "millimeter");
    assert_eq!(results[1].output, "2000");
}

#[test]
fn bridge_dtos_use_documented_camel_case_rounding_identifiers() {
    let encoded = serde_json::to_value(request("1", "meter", "centimeter"))
        .expect("bridge request serializes");

    assert_eq!(encoded["fromUnitId"].as_str(), Some("meter"));
    assert_eq!(encoded["toUnitId"].as_str(), Some("centimeter"));
    assert_eq!(encoded["roundMode"].as_str(), Some("nearestEven"));
    assert!(encoded.get("from_unit_id").is_none());
}
