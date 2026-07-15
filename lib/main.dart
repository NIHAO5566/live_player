import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '直播播放器',
      theme: ThemeData.dark(),
      home: LivePlayerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LivePlayerPage extends StatefulWidget {
  @override
  _LivePlayerPageState createState() => _LivePlayerPageState();
}

class _LivePlayerPageState extends State<LivePlayerPage> {
  final TextEditingController _urlController = TextEditingController();
  VideoPlayerController? _controller;
  double _speed = 1.2;
  String _status = '就绪';

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: Duration(seconds: 2)),
    );
  }

  void _play() async {
    var url = _urlController.text.trim();
    if (url.isEmpty) {
      _showMsg('请输入FLV地址');
      return;
    }
    if (!url.contains('.flv') && !url.contains('douyincdn')) {
      _showMsg('请输入有效的FLV地址');
      return;
    }

    setState(() => _status = '加载中...');

    try {
      _controller?.dispose();
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await _controller!.initialize();
      await _controller!.setVolume(1.0);
      await _controller!.setLooping(false);
      await _controller!.play();
      _controller!.setPlaybackSpeed(_speed);

      setState(() => _status = '播放中 (${_speed}x)');
      _showMsg('播放成功');
      _showPlayerView();
    } catch (e) {
      setState(() => _status = '播放失败');
      _showMsg('播放失败');
    }
  }

  void _showPlayerView() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              if (_controller != null && _controller!.value.isInitialized)
                AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    _controller?.pause();
                    setState(() => _status = '已停止');
                    Navigator.pop(context);
                  },
                ),
              ),
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSpeedBtn(1.0),
                    _buildSpeedBtn(1.2),
                    _buildSpeedBtn(1.5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedBtn(double speed) {
    bool isActive = _speed == speed;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.blue : Colors.grey[800],
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          setState(() => _speed = speed);
          _controller?.setPlaybackSpeed(speed);
          setState(() => _status = '播放中 (${speed}x)');
          _showMsg('切换至 ${speed}x');
        },
        child: Text('${speed}x'),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a1a2e),
      appBar: AppBar(
        title: Text('直播播放器'),
        backgroundColor: Color(0xFF16213e),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.live_tv, size: 80, color: Colors.blue[300]),
            SizedBox(height: 20),
            Text('低延迟直播播放器', style: TextStyle(fontSize: 20, color: Colors.grey[400])),
            SizedBox(height: 40),
            TextField(
              controller: _urlController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '粘贴 FLV 流地址...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Color(0xFF16213e),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.link, color: Colors.grey[500]),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _play,
              child: Text('▶ 播放', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 30),
            Text(_status, style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}