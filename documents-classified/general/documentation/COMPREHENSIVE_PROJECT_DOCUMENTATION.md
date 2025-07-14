#### SSE 연결
```javascript
const eventSource = new EventSource('/api/v1/notifications/stream');
eventSource.onmessage = function(event) {
    const notification = JSON.parse(event.data);
    console.log('알림 수신:', notification);
};
```