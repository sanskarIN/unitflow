use unitflow_core::{
    BridgeBatchConversionRequest, BridgeConversionRequest, BridgeCustomUnit, BridgeService,
    Category, RoundMode, BRIDGE_BACKEND_ID, BRIDGE_CAPABILITIES,
    BRIDGE_CAPABILITY_BATCH_CONVERT, BRIDGE_CAPABILITY_CANONICAL_DECIMAL_TEXT,
    BRIDGE_CAPABILITY_CONVERT, BRIDGE_MAX_BATCH_TARGETS, BRIDGE_MAX_CUSTOM_UNITS,
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

fn custom_unit(id: &str, scale: &str) -> BridgeCustomUnit {
    BridgeCustomUnit {
        id: id.to_owned(),
        category: Category::Length,
        name: "Custom Length".to_owned(),
        symbol: "cl".to_owned(),
        aliases: vec!["custom length".to_owned()],
        description: "Synthetic bridge catalog fixture.".to_owned(),
        scale: scale.to_owned(),
        offset: "0".to_owned(),
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
fn rejects_malformed_unit_identifiers_before_catalog_lookup() {
    let service = BridgeService::with_built_in_catalog().expect("built-in bridge service");
    let failure = service
        .convert(request("1", "../meter", "centimeter"))
        .expect_err("malformed unit identifier must fail");

    assert_eq!(failure.code, "unknown_unit");
    assert!(!failure.message.contains("../meter"));
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
fn rejects_oversized_batch_requests_before_conversion() {
    let service = BridgeService::with_built_in_catalog().expect("built-in bridge service");
    let failure = service
        .batch_convert(BridgeBatchConversionRequest {
            value: "2".to_owned(),
            from_unit_id: "meter".to_owned(),
            target_unit_ids: vec!["centimeter".to_owned(); BRIDGE_MAX_BATCH_TARGETS + 1],
            decimal_places: None,
            round_mode: RoundMode::NearestEven,
        })
        .expect_err("oversized batch must fail before conversion");

    assert_eq!(failure.code, "invalid_batch");
    assert!(!failure.message.contains("centimeter"));
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

#[test]
fn replaces_custom_catalog_snapshot_and_converts_with_new_unit() {
    let mut service = BridgeService::with_built_in_catalog().expect("built-in bridge service");
    service
        .replace_custom_units(vec![custom_unit("double_meter", "2")])
        .expect("custom catalog snapshot should validate");

    let result = service
        .convert(request("3", "double_meter", "meter"))
        .expect("custom unit should be active");
    assert_eq!(result.output, "6");
}

#[test]
fn replacing_snapshot_removes_units_not_present_in_new_snapshot() {
    let mut service = BridgeService::with_built_in_catalog().expect("built-in bridge service");
    service
        .replace_custom_units(vec![custom_unit("first_custom", "2")])
        .expect("first snapshot");
    service
        .replace_custom_units(vec![custom_unit("second_custom", "3")])
        .expect("second snapshot");

    let stale = service
        .convert(request("1", "first_custom", "meter"))
        .expect_err("removed custom unit must not remain active");
    assert_eq!(stale.code, "unknown_unit");

    let current = service
        .convert(request("2", "second_custom", "meter"))
        .expect("replacement unit should be active");
    assert_eq!(current.output, "6");
}

#[test]
fn invalid_snapshot_does_not_replace_previous_valid_catalog() {
    let mut service = BridgeService::with_built_in_catalog().expect("built-in bridge service");
    service
        .replace_custom_units(vec![custom_unit("stable_custom", "2")])
        .expect("initial snapshot");

    let failure = service
        .replace_custom_units(vec![custom_unit("bad_custom", "1.0")])
        .expect_err("non-canonical scale must fail");
    assert_eq!(failure.code, "invalid_decimal");

    let result = service
        .convert(request("4", "stable_custom", "meter"))
        .expect("previous catalog must remain active after rejected snapshot");
    assert_eq!(result.output, "8");
}

#[test]
fn rejects_oversized_custom_catalog_snapshot() {
    let mut service = BridgeService::with_built_in_catalog().expect("built-in bridge service");
    let units = (0..=BRIDGE_MAX_CUSTOM_UNITS)
        .map(|index| custom_unit(&format!("custom_{index}"), "2"))
        .collect();

    let failure = service
        .replace_custom_units(units)
        .expect_err("oversized custom catalog must be rejected");
    assert_eq!(failure.code, "invalid_catalog_snapshot");
}

#[test]
fn custom_unit_bridge_dto_uses_canonical_string_fields() {
    let encoded = serde_json::to_value(custom_unit("double_meter", "2"))
        .expect("custom unit serializes");

    assert_eq!(encoded["id"].as_str(), Some("double_meter"));
    assert_eq!(encoded["category"].as_str(), Some("length"));
    assert_eq!(encoded["scale"].as_str(), Some("2"));
    assert_eq!(encoded["offset"].as_str(), Some("0"));
}
