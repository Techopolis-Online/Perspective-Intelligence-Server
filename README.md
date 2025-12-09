# Perspective Intelligence

A macOS menu bar application that bridges Apple Intelligence (on-device Foundation Models) with OpenAI and Ollama-compatible API endpoints. Run AI locally on your Mac without sending data to external servers.

## Features

- **Local HTTP Server**: Exposes Apple Intelligence through standard API endpoints
- **OpenAI API Compatible**: Drop-in replacement for OpenAI API clients
- **Ollama API Compatible**: Works with applications that support Ollama
- **Menu Bar Integration**: Start, stop, and configure the server from your menu bar
- **Built-in Chat Interface**: Test the AI directly within the app
- **Streaming Support**: Server-sent events (SSE) and NDJSON streaming
- **Tool Calling**: Basic file system tools (read, write, list directory)
- **Privacy First**: All processing happens on-device

## Requirements

- macOS 26.0 (Tahoe) or later
- Apple Silicon Mac (M1 or later)
- Apple Intelligence enabled on your device
- Xcode 26.0 or later (for building from source)

## Installation

### Building from Source

1. Clone the repository:

```bash
git clone https://github.com/yourusername/Perspective-Intelligence-Server.git
cd Perspective-Intelligence-Server
```

2. Open the project in Xcode:

```bash
open "Perspective Intelligence.xcodeproj"
```

3. Select your development team in the project settings under Signing and Capabilities.

4. Build and run the project (Cmd + R).

## Getting Started

### Starting the Server

1. Launch Perspective Intelligence. The app appears in your menu bar with a lightning bolt icon.
2. The server starts automatically on port 11434 when the app launches.
3. Click the menu bar icon to view server status and controls.
4. The status indicator is green when the server is running.
5. Use the controls to stop, restart, or change the port if needed.

### Testing with the Built-in Chat

1. Open the Chat window from the menu bar or use the keyboard shortcut.
2. Type a message and press Return or click Send.
3. The response comes from Apple Intelligence running locally on your Mac.

### Configuring Settings

Open Settings (Cmd + ,) to configure:

- **Include System Prompt**: Toggle whether to send a system instruction with each request
- **Enable Debug Logging**: Print requests and responses to the console
- **Include Conversation History**: Send full conversation context or just the latest message
- **System Prompt**: Customize the AI's behavior with your own instructions

## API Reference

The server exposes OpenAI and Ollama-compatible endpoints at `http://127.0.0.1:11434` (or your configured port).

### OpenAI-Compatible Endpoints

#### Chat Completions

```bash
curl http://127.0.0.1:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "apple.local",
    "messages": [
      {"role": "user", "content": "Hello, how are you?"}
    ]
  }'
```

#### Chat Completions with Streaming

```bash
curl http://127.0.0.1:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "apple.local",
    "messages": [
      {"role": "user", "content": "Write a short poem about coding"}
    ],
    "stream": true
  }'
```

#### Text Completions

```bash
curl http://127.0.0.1:11434/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "apple.local",
    "prompt": "The quick brown fox"
  }'
```

#### List Models

```bash
curl http://127.0.0.1:11434/v1/models
```

#### Get Model Details

```bash
curl http://127.0.0.1:11434/v1/models/apple.local
```

### Ollama-Compatible Endpoints

#### Chat

```bash
curl http://127.0.0.1:11434/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "apple.local",
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

#### Generate

```bash
curl http://127.0.0.1:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "apple.local",
    "prompt": "Explain quantum computing in simple terms"
  }'
```

#### List Tags (Models)

```bash
curl http://127.0.0.1:11434/api/tags
```

#### Version

```bash
curl http://127.0.0.1:11434/api/version
```

### Debug Endpoints

#### Health Check

```bash
curl http://127.0.0.1:11434/debug/health
```

#### Echo (for debugging requests)

```bash
curl -X POST http://127.0.0.1:11434/debug/echo \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

## Using with Third-Party Applications

### Cursor IDE

Configure Cursor to use the local server:

1. Open Cursor Settings
2. Navigate to AI settings
3. Set the API base URL to `http://127.0.0.1:11434/v1`
4. Use `apple.local` as the model name

### Continue.dev

Add to your Continue configuration:

```json
{
  "models": [
    {
      "title": "Apple Intelligence",
      "provider": "openai",
      "model": "apple.local",
      "apiBase": "http://127.0.0.1:11434/v1"
    }
  ]
}
```

### Other OpenAI-Compatible Clients

Any application that supports custom OpenAI API endpoints can use Perspective Intelligence:

- Set the API base URL to `http://127.0.0.1:11434/v1`
- Use `apple.local` as the model name
- API key is not required (but can be set to any value if the client requires it)

## Tool Calling

The server supports basic tool calling for file operations within a sandboxed workspace:

### Available Tools

- `read_file`: Read file contents
- `write_file`: Write content to a file
- `list_dir`: List directory contents

### Workspace Configuration

Set the `PI_WORKSPACE_ROOT` environment variable to specify the root directory for file operations. If not set, it defaults to your Documents folder.

```bash
export PI_WORKSPACE_ROOT=/path/to/your/workspace
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PI_WORKSPACE_ROOT` | Root directory for tool file operations | `~/Documents` |
| `PI_DEBUG_FULL_LOG` | Set to `1` to enable full request body logging | Disabled |

## Troubleshooting

### Server won't start

- Ensure you're running macOS 26.0 (Tahoe) or later on Apple Silicon
- Check that Apple Intelligence is enabled in System Settings
- Verify the port isn't already in use by another application

### Model not available

If you see "Model not ready" errors:

1. Open System Settings
2. Navigate to Apple Intelligence and Siri
3. Ensure Apple Intelligence is enabled and fully downloaded

### Empty or fallback responses

The server returns a fallback response when:

- Apple Intelligence is not available on your device
- The on-device model is still downloading
- Safety guardrails block the request

Check the console logs (enable Debug Logging in Settings) for more details.

### Port conflicts

If port 11434 is in use (e.g., by Ollama), change the port in the menu bar controls before starting the server.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source. See the LICENSE file for details.

## Acknowledgments

- Apple for Foundation Models and on-device AI capabilities
- The OpenAI API specification that enables broad compatibility
- The Ollama project for their API design inspiration
