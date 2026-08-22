import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qde_eco_bahor/core/di/injection_container.dart';
import 'package:qde_eco_bahor/core/theme/theme_dimensions.dart';
import 'package:qde_eco_bahor/core/widgets/error_widget.dart';
import 'package:qde_eco_bahor/core/widgets/language_toggle.dart';
import 'package:qde_eco_bahor/core/widgets/loading_widget.dart';
import 'package:qde_eco_bahor/core/widgets/theme_toggle.dart';
import 'package:qde_eco_bahor/features/example_feature/domain/entities/example_entity.dart';
import 'package:qde_eco_bahor/features/example_feature/presentation/bloc/example_bloc.dart';
import 'package:qde_eco_bahor/features/example_feature/presentation/widgets/example_list_item.dart';
import 'package:qde_eco_bahor/generated/locale_keys.g.dart';

/// Страница с примером использования Clean Architecture и BLoC
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ExampleBloc>()..add(const ExampleEvent.getExampleData()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
          title: Text(LocaleKeys.example_title.tr()),
          actions: const [
            LanguageToggle(),
            ThemeToggle(),
          ],
        ),
        body: BlocBuilder<ExampleBloc, ExampleState>(
          builder: (context, state) {
            return state.maybeWhen(
              initial: () => const SizedBox.shrink(),
              loading: () => LoadingWidget(
                message: LocaleKeys.common_loading.tr(),
              ),
              loaded: (data) => _ExampleListWithRefresh(data: data),
              error: (failure) => ErrorDisplayWidget(
                failure: failure,
                onRetry: () {
                  context.read<ExampleBloc>().add(
                        const ExampleEvent.getExampleData(),
                      );
                },
              ),
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

/// Виджет списка с pull-to-refresh
class _ExampleListWithRefresh extends StatefulWidget {
  final List<ExampleEntity> data;

  const _ExampleListWithRefresh({required this.data});

  @override
  State<_ExampleListWithRefresh> createState() => _ExampleListWithRefreshState();
}

class _ExampleListWithRefreshState extends State<_ExampleListWithRefresh> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    context.read<ExampleBloc>().add(
          const ExampleEvent.refreshExampleData(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExampleBloc, ExampleState>(
      listener: (context, state) {
        state.maybeWhen(
          loaded: (_) {
            if (_refreshController.isRefresh) {
              _refreshController.refreshCompleted();
            }
          },
          error: (_) {
            if (_refreshController.isRefresh) {
              _refreshController.refreshFailed();
            }
          },
          orElse: () {},
        );
      },
      child: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        enablePullDown: true,
        header: const WaterDropHeader(),
        child: ListView.builder(
          padding: EdgeInsets.all(ThemeDimensions.paddingM),
          itemCount: widget.data.length,
          itemBuilder: (context, index) {
            return ExampleListItem(entity: widget.data[index]);
          },
        ),
      ),
    );
  }
}
