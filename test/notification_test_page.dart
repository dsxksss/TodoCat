import 'package:flutter/material.dart';
import 'package:TodoCat/widgets/show_toast.dart';

/// 通知系统测试页面
class NotificationTestPage extends StatelessWidget {
  const NotificationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知系统测试'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '点击按钮测试悬停暂停功能',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              '请观察控制台输出来调试悬停功能',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                showSuccessNotification('悬停测试通知 ${DateTime.now().millisecondsSinceEpoch % 1000}');
              },
              child: const Text('显示成功通知'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                showErrorNotification('错误测试通知 ${DateTime.now().millisecondsSinceEpoch % 1000}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('显示错误通知'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                showInfoNotification('信息测试通知 ${DateTime.now().millisecondsSinceEpoch % 1000}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('显示信息通知'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // 快速显示多个通知测试全局悬停
                for (int i = 1; i <= 3; i++) {
                  Future.delayed(Duration(milliseconds: i * 200), () {
                    showSuccessNotification('批量通知 $i - 悬停任何一个应该暂停全部');
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('测试批量通知悬停'),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '测试说明：\n'
                '1. 显示通知后立即悬停，观察是否暂停\n'
                '2. 检查控制台输出是否有暂停/恢复日志\n'
                '3. 悬停任何通知应该暂停所有通知\n'
                '4. 离开悬停应该恢复所有通知的计时',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}