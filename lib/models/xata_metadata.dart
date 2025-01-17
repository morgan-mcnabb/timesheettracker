class XataMetadata {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  XataMetadata({
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory XataMetadata.fromJson(Map<String, dynamic> json) {
    return XataMetadata(
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (version != null) 'version': version,
    };
  }
}
