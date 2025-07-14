import 'package:flutter/material.dart';

void main() {
  runApp(const JBReportSimpleApp());
}

class JBReportSimpleApp extends StatelessWidget {
  const JBReportSimpleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JB Report Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JB Report Platform'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.report_problem,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'JB Report Platform',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '시민 신고 및 제보 플랫폼',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 40),
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '프로덕션 앱이 성공적으로 실행되었습니다!\n'
                  'Freezed 코드 생성 이슈를 해결한 후\n'
                  '완전한 기능을 사용할 수 있습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('JB Report 프로덕션 앱이 실행 중입니다!'),
            ),
          );
        },
        tooltip: '신고하기',
        child: const Icon(Icons.add),
      ),
    );
  }
}