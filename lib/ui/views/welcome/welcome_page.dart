import 'package:flutter/material.dart';
import 'package:peak_pass/ui/views/welcome/welcome_body.dart';
import 'package:peak_pass/ui/views/welcome/welcome_body_empty.dart';
import 'package:peak_pass/ui/views/welcome/welcome_footer.dart';
import 'package:peak_pass/ui/views/welcome/welcome_header.dart';
import 'package:peak_pass/view_models/file_provider.dart';
import 'package:provider/provider.dart';

/// 数据文件选择页面
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  static const String routeName = 'welcome';

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  /// 动画效果:
  ///  - Header  opacity
  ///  - Body slides x + opacity
  ///  - Footer slides y +  opacity
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Durations.short3);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
  }

  void _toggle() {
    if (_controller.status == AnimationStatus.completed) {
      // normal -> editing
      _controller.reverse();

      // 当页面切到normal状态时, 要清空选中的
      context.read<FileProvider>().clearSelects();
    } else {
      // editing -> normal
      _controller.forward();
    }
    // 在这里添加setState保证只 build一次, 而不是 在addListener中  rebuild多次
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = context.watch<FileProvider>();

    Widget? childWidget;
    if (fileProvider.isRecycleBinPage) {
      childWidget =
          fileProvider.recycleModels.isEmpty
              ? WelcomeBodyEmpty(isRecycleBin: true)
              : WelcomeBody(
                databaseInfo: fileProvider.recycleModels,
                animation: _animation,
              );
    } else {
      childWidget =
          fileProvider.models.isEmpty
              ? WelcomeBodyEmpty(isRecycleBin: false)
              : WelcomeBody(
                databaseInfo: fileProvider.models,
                animation: _animation,
              );
    }

    return Scaffold(
      appBar: WelcomeHeader(
        onToggle: () {
          _toggle();
        },
        animation: _animation,
      ),
      // Body
      body: RefreshIndicator(
        onRefresh: () async {
          await fileProvider.reload();
        },
        child: Scrollbar(
          radius: Radius.circular(8),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: childWidget,
          ),
        ),
      ),
      // Footer
      floatingActionButton: WelcomeFooter(
        alignment:
            fileProvider.models.isEmpty ? Axis.vertical : Axis.horizontal,
        animation: _animation,
      ),
      // https://stackoverflow.com/questions/53463461/how-to-set-custom-offset-to-floatingactionbuttonlocation-in-the-scaffold-in-f/53463898#53463898
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
