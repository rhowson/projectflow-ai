// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_role_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeProjectHash() => r'2f08a5ec5f85dde01fd1190b3f26d789307cfb39';

/// Combined provider for active project roles (convenience)
///
/// Copied from [activeProject].
@ProviderFor(activeProject)
final activeProjectProvider = AutoDisposeFutureProvider<Project?>.internal(
  activeProject,
  name: r'activeProjectProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeProjectHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveProjectRef = AutoDisposeFutureProviderRef<Project?>;
String _$projectRoleNotifierHash() =>
    r'1243b50dc454916a9b8ad901a5696f99f7121647';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ProjectRoleNotifier
    extends BuildlessAutoDisposeNotifier<AsyncValue<List<ProjectRole>>> {
  late final String projectId;

  AsyncValue<List<ProjectRole>> build(
    String projectId,
  );
}

/// Provider for managing project roles
///
/// Copied from [ProjectRoleNotifier].
@ProviderFor(ProjectRoleNotifier)
const projectRoleNotifierProvider = ProjectRoleNotifierFamily();

/// Provider for managing project roles
///
/// Copied from [ProjectRoleNotifier].
class ProjectRoleNotifierFamily extends Family<AsyncValue<List<ProjectRole>>> {
  /// Provider for managing project roles
  ///
  /// Copied from [ProjectRoleNotifier].
  const ProjectRoleNotifierFamily();

  /// Provider for managing project roles
  ///
  /// Copied from [ProjectRoleNotifier].
  ProjectRoleNotifierProvider call(
    String projectId,
  ) {
    return ProjectRoleNotifierProvider(
      projectId,
    );
  }

  @override
  ProjectRoleNotifierProvider getProviderOverride(
    covariant ProjectRoleNotifierProvider provider,
  ) {
    return call(
      provider.projectId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectRoleNotifierProvider';
}

/// Provider for managing project roles
///
/// Copied from [ProjectRoleNotifier].
class ProjectRoleNotifierProvider extends AutoDisposeNotifierProviderImpl<
    ProjectRoleNotifier, AsyncValue<List<ProjectRole>>> {
  /// Provider for managing project roles
  ///
  /// Copied from [ProjectRoleNotifier].
  ProjectRoleNotifierProvider(
    String projectId,
  ) : this._internal(
          () => ProjectRoleNotifier()..projectId = projectId,
          from: projectRoleNotifierProvider,
          name: r'projectRoleNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$projectRoleNotifierHash,
          dependencies: ProjectRoleNotifierFamily._dependencies,
          allTransitiveDependencies:
              ProjectRoleNotifierFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  ProjectRoleNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final String projectId;

  @override
  AsyncValue<List<ProjectRole>> runNotifierBuild(
    covariant ProjectRoleNotifier notifier,
  ) {
    return notifier.build(
      projectId,
    );
  }

  @override
  Override overrideWith(ProjectRoleNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProjectRoleNotifierProvider._internal(
        () => create()..projectId = projectId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ProjectRoleNotifier,
      AsyncValue<List<ProjectRole>>> createElement() {
    return _ProjectRoleNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectRoleNotifierProvider && other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProjectRoleNotifierRef
    on AutoDisposeNotifierProviderRef<AsyncValue<List<ProjectRole>>> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _ProjectRoleNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<ProjectRoleNotifier,
        AsyncValue<List<ProjectRole>>> with ProjectRoleNotifierRef {
  _ProjectRoleNotifierProviderElement(super.provider);

  @override
  String get projectId => (origin as ProjectRoleNotifierProvider).projectId;
}

String _$projectRoleAssignmentNotifierHash() =>
    r'5032966dfbfc247e8c00679c43b044850bfe51e5';

abstract class _$ProjectRoleAssignmentNotifier
    extends BuildlessAutoDisposeNotifier<
        AsyncValue<List<ProjectRoleAssignment>>> {
  late final String projectId;

  AsyncValue<List<ProjectRoleAssignment>> build(
    String projectId,
  );
}

/// Provider for project role assignments
///
/// Copied from [ProjectRoleAssignmentNotifier].
@ProviderFor(ProjectRoleAssignmentNotifier)
const projectRoleAssignmentNotifierProvider =
    ProjectRoleAssignmentNotifierFamily();

/// Provider for project role assignments
///
/// Copied from [ProjectRoleAssignmentNotifier].
class ProjectRoleAssignmentNotifierFamily
    extends Family<AsyncValue<List<ProjectRoleAssignment>>> {
  /// Provider for project role assignments
  ///
  /// Copied from [ProjectRoleAssignmentNotifier].
  const ProjectRoleAssignmentNotifierFamily();

  /// Provider for project role assignments
  ///
  /// Copied from [ProjectRoleAssignmentNotifier].
  ProjectRoleAssignmentNotifierProvider call(
    String projectId,
  ) {
    return ProjectRoleAssignmentNotifierProvider(
      projectId,
    );
  }

  @override
  ProjectRoleAssignmentNotifierProvider getProviderOverride(
    covariant ProjectRoleAssignmentNotifierProvider provider,
  ) {
    return call(
      provider.projectId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectRoleAssignmentNotifierProvider';
}

/// Provider for project role assignments
///
/// Copied from [ProjectRoleAssignmentNotifier].
class ProjectRoleAssignmentNotifierProvider
    extends AutoDisposeNotifierProviderImpl<ProjectRoleAssignmentNotifier,
        AsyncValue<List<ProjectRoleAssignment>>> {
  /// Provider for project role assignments
  ///
  /// Copied from [ProjectRoleAssignmentNotifier].
  ProjectRoleAssignmentNotifierProvider(
    String projectId,
  ) : this._internal(
          () => ProjectRoleAssignmentNotifier()..projectId = projectId,
          from: projectRoleAssignmentNotifierProvider,
          name: r'projectRoleAssignmentNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$projectRoleAssignmentNotifierHash,
          dependencies: ProjectRoleAssignmentNotifierFamily._dependencies,
          allTransitiveDependencies:
              ProjectRoleAssignmentNotifierFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  ProjectRoleAssignmentNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final String projectId;

  @override
  AsyncValue<List<ProjectRoleAssignment>> runNotifierBuild(
    covariant ProjectRoleAssignmentNotifier notifier,
  ) {
    return notifier.build(
      projectId,
    );
  }

  @override
  Override overrideWith(ProjectRoleAssignmentNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProjectRoleAssignmentNotifierProvider._internal(
        () => create()..projectId = projectId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ProjectRoleAssignmentNotifier,
      AsyncValue<List<ProjectRoleAssignment>>> createElement() {
    return _ProjectRoleAssignmentNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectRoleAssignmentNotifierProvider &&
        other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProjectRoleAssignmentNotifierRef
    on AutoDisposeNotifierProviderRef<AsyncValue<List<ProjectRoleAssignment>>> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _ProjectRoleAssignmentNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<ProjectRoleAssignmentNotifier,
        AsyncValue<List<ProjectRoleAssignment>>>
    with ProjectRoleAssignmentNotifierRef {
  _ProjectRoleAssignmentNotifierProviderElement(super.provider);

  @override
  String get projectId =>
      (origin as ProjectRoleAssignmentNotifierProvider).projectId;
}

String _$aIRoleGenerationNotifierHash() =>
    r'bffae15aa2b03cb788210dae44d28e29c43dc383';

/// Provider for AI role generation state
///
/// Copied from [AIRoleGenerationNotifier].
@ProviderFor(AIRoleGenerationNotifier)
final aIRoleGenerationNotifierProvider = AutoDisposeNotifierProvider<
    AIRoleGenerationNotifier, AsyncValue<List<AIRoleSuggestion>?>>.internal(
  AIRoleGenerationNotifier.new,
  name: r'aIRoleGenerationNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aIRoleGenerationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AIRoleGenerationNotifier
    = AutoDisposeNotifier<AsyncValue<List<AIRoleSuggestion>?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
