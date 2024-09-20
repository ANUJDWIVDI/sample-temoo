<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.net.*, java.nio.charset.StandardCharsets, java.util.ArrayList" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>Chatbot using Gemini 1.5 API</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    <script>
        function setPromptText(prompt) {
            document.getElementById("message").value = prompt;
        }
    </script>
</head>
<body class="container">
    <h1 class="mt-5">Chatbot</h1>

    <form method="post" action="index.jsp" class="mb-3">
        <div class="form-group">
            <label for="message">Enter your message:</label>
            <h2>Sample Prompts</h2>
            <ul>
                <li><a href="javascript:void(0);" onclick="setPromptText('What is the capital of France?')">What is the capital of France?</a></li>
                <li><a href="javascript:void(0);" onclick="setPromptText('Tell me a joke.')">Tell me a joke.</a></li>
                <li><a href="javascript:void(0);" onclick="setPromptText('What is the weather like today?')">What is the weather like today?</a></li>
                <li><a href="javascript:void(0);" onclick="setPromptText('Explain the theory of relativity.')">Explain the theory of relativity.</a></li>
            </ul>
            <input type="text" id="message" name="message" class="form-control" required>
        </div>
        <button type="submit" class="btn btn-primary">Send</button>
    </form>

    <%
        // Retrieve or initialize chat history
        ArrayList<String[]> chatHistory = (ArrayList<String[]>) session.getAttribute("chatHistory");
        if (chatHistory == null) {
            chatHistory = new ArrayList<>();
        }

        // Handle form submission and chat processing
        String message = request.getParameter("message");
        if (message != null && !message.isEmpty()) {
            String apiKey = "AIzaSyAU_yylyXkc9myUZ_59V9Sjy7--5xmYcpE"; // Replace with your actual API key
            String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=" + apiKey;
            String responseText = "";

            try {
                // Create JSON request body
                String jsonBody = "{\"contents\":[{\"parts\":[{\"text\":\"" + message + "\"}]}]}";

                // Create HTTP connection
                URL url = new URL(apiUrl);
                HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                connection.setRequestMethod("POST");
                connection.setRequestProperty("Content-Type", "application/json");
                connection.setDoOutput(true);

                // Send request
                OutputStream os = connection.getOutputStream();
                byte[] input = jsonBody.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);

                // Read response
                BufferedReader br = new BufferedReader(new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8));
                StringBuilder responseBuilder = new StringBuilder();
                String responseLine;
                while ((responseLine = br.readLine()) != null) {
                    responseBuilder.append(responseLine.trim());
                }

                // Extract response text (adjust depending on the response format)
                String jsonResponse = responseBuilder.toString();
                int startIndex = jsonResponse.indexOf("\"text\": \"") + 9;
                int endIndex = jsonResponse.indexOf("\"", startIndex);
                responseText = jsonResponse.substring(startIndex, endIndex);

                // Add conversation to chat history
                chatHistory.add(new String[]{"You", message});
                chatHistory.add(new String[]{"Chatbot", responseText});

                // Update session with chat history
                session.setAttribute("chatHistory", chatHistory);

            } catch (Exception e) {
                responseText = "Error: " + e.getMessage();
                chatHistory.add(new String[]{"Chatbot", responseText});
                session.setAttribute("chatHistory", chatHistory);
            }
        }

        // Display chat history
        if (!chatHistory.isEmpty()) {
            out.println("<h3>Chat History:</h3>");
            out.println("<div class='border p-3 mb-3' style='max-height: 300px; overflow-y: auto;'>");
            for (String[] chat : chatHistory) {
                out.println("<p><strong>" + chat[0] + ":</strong> " + chat[1] + "</p>");
            }
            out.println("</div>");
        }
    %>

   

</body>
</html>