const express = require('express');
const { spawn } = require('child_process');
const fs = require('fs');
const cors = require('cors');
const app = express();
const port = 3000;
require('dotenv').config();
app.use(cors());
app.use(express.json());
// Existing scrape endpoint
app.get('/scrape', (req, res) => {
    const query = req.query.query;
    
    if (!query) {
        return res.status(400).json({ error: "Query parameter is required" });
    }

    const pythonProcess = spawn('python', ['orchestrator.py', query]);

    pythonProcess.stderr.on('data', (data) => {
        console.error(`Python Error: ${data}`);
    });

    pythonProcess.on('close', (code) => {
        if (code !== 0) {
            return res.status(500).json({
                error: 'Scraping failed',
                details: `Process exited with code ${code}`
            });
        }

        fs.readFile('all_courses.json', 'utf8', (err, data) => {
            if (err) {
                return res.status(500).json({
                    error: 'Could not read results file',
                    details: err.message
                });
            }

            try {
                const jsonData = JSON.parse(data);
                res.json(jsonData);
            } catch (e) {
                res.status(500).json({
                    error: 'Invalid JSON format',
                    details: e.message
                });
            }
        });
    });
});
app.post('/compare', (req, res) => {
    const [course1, course2] = req.body;
    console.log("/compare hit")
    if (!course1 || !course2) {
        return res.status(400).json({ error: "Both courses are required in the request body" });
    }

    const url1 = course1.product_link;
    const url2 = course2.product_link;

    if (!url1 || !url2) {
        return res.status(400).json({ error: "Both courses must have a product_link" });
    }
    
    const pythonProcess = spawn('python', ['ai_cpm_v2.py', url1, url2]);

    let comparisonResult = '';
    pythonProcess.stdout.on('data', (data) => {
        comparisonResult += data.toString();
    });

    pythonProcess.stderr.on('data', (data) => {
        console.error(`Python Error: ${data}`);
    });

    pythonProcess.on('close', (code) => {
        if (code !== 0) {
            return res.status(500).json({
                error: 'Comparison failed',
                details: `Process exited with code ${code}`
            });
        }

        try {
            // Parse the Python output and send directly
            const parsedResult = JSON.parse(comparisonResult.trim());
            res.json(parsedResult);
        } catch (e) {
            res.status(500).json({
                error: 'Invalid JSON from Python script',
                details: e.message
            });
        }
    });
});
app.post('/airec', (req, res) => {
    console.log("hit airec")
    const { query } = req.body;

    if (!query) {
        return res.status(400).json({ error: "Query parameter is required in the request body" });
    }

    const pythonProcess = spawn('python', ['ai_recom.py', query]);

    let resultData = '';
    pythonProcess.stdout.on('data', (data) => {
        resultData += data.toString();
    });

    pythonProcess.stderr.on('data', (data) => {
        console.error(`Python Error: ${data}`);
    });

    pythonProcess.on('close', (code) => {
        if (code !== 0) {
            return res.status(500).json({
                error: 'AI recommendation failed',
                details: `Process exited with code ${code}`
            });
        }

        try {
            // Parse the Python output as JSON
            const jsonResult = JSON.parse(resultData);
            res.json(jsonResult);
        } catch (e) {
            res.status(500).json({
                error: 'Invalid JSON from Python script',
                details: e.message
            });
        }
    });
});
// Helper ChatbOT
app.post('/chat', async (req, res) => {
    try {
        const { message, session_id = 'default', history = [] } = req.body;
        const api_key = process.env.API_KEY; // Get from environment variables

        if (!message) {
            return res.status(400).json({ error: 'Message is required' });
        }

        // Prepare the input data
        const inputData = {
            api_key: api_key,
            message: message,
            session_id: session_id,
            history: history
        };

        // Spawn Python process
        const pythonProcess = spawn('python', ['ai_chatbot.py', JSON.stringify(inputData)]);

        let result = '';
        let error = '';

        // Collect data from Python script
        pythonProcess.stdout.on('data', (data) => {
            result += data.toString();
        });

        pythonProcess.stderr.on('data', (data) => {
            error += data.toString();
        });

        // Handle process completion
        pythonProcess.on('close', (code) => {
            if (code !== 0 || error) {
                return res.status(500).json({
                    error: error || 'Python process failed',
                    session_id,
                    history: []
                });
            }

            try {
                const response = JSON.parse(result);
                res.json({
                    response: response.response,
                    history: response.history,
                    session_id: response.session_id,
                    error: response.error
                });
            } catch (parseError) {
                res.status(500).json({
                    error: 'Failed to parse response',
                    session_id,
                    history: []
                });
            }
        });

    } catch (error) {
        res.status(500).json({
            error: error.message,
            session_id: req.body.session_id || 'default',
            history: []
        });
    }
});
app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});