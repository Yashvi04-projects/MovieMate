const express = require('express');
const { readJSON, writeJSON } = require('../utils/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// GET /movies
router.get('/', (req, res) => {
  try {
    const movies = readJSON('movies.json');
    const { genre, trending, upcoming } = req.query;

    let filtered = [...movies];

    if (genre) {
      // BUG-07: Case-sensitive genre filter on API
      filtered = filtered.filter((m) => m.genre === genre);
    }
    if (trending === 'true') {
      filtered = filtered.filter((m) => m.trending);
    }
    if (upcoming === 'true') {
      filtered = filtered.filter((m) => m.upcoming);
    }

    console.log('[MOVIES] Returning', filtered.length, 'movies');
    return res.status(200).json({
      success: true,
      count: filtered.length,
      data: filtered,
    });
  } catch (err) {
    console.error('[MOVIES] Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
});

// GET /movies/search?q= - BUG-07 & BUG-08 on search
router.get('/search', (req, res) => {
  try {
    const { q, genre } = req.query;
    const movies = readJSON('movies.json');

    if (!q && !genre) {
      return res.status(400).json({
        success: false,
        message: 'Search query or genre is required',
      });
    }

    let results = movies;

    if (q) {
      // BUG-07: Case-sensitive search
      // BUG-08: Extra spaces break search (exact match only, no trim)
      results = results.filter(
        (m) => m.name.includes(q) || m.genre.includes(q)
      );
    }

    if (genre) {
      results = results.filter((m) => m.genre === genre);
    }

    console.log('[SEARCH] Query:', q, 'Results:', results.length);
    return res.status(200).json({
      success: true,
      count: results.length,
      data: results,
    });
  } catch (err) {
    console.error('[SEARCH] Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
});

// GET /movies/:id
router.get('/:id', (req, res) => {
  try {
    const movies = readJSON('movies.json');
    const movie = movies.find((m) => m.id === req.params.id);

    if (!movie) {
      console.log('[MOVIE] Not found:', req.params.id);
      return res.status(404).json({
        success: false,
        message: 'Movie not found',
      });
    }

    console.log('[MOVIE] Returning:', movie.name);
    return res.status(200).json({
      success: true,
      data: movie,
    });
  } catch (err) {
    console.error('[MOVIE] Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
});

// POST /movies - for Postman CRUD testing
router.post('/', authMiddleware, (req, res) => {
  try {
    const movies = readJSON('movies.json');
    const newMovie = {
      id: String(movies.length + 1),
      ...req.body,
    };
    movies.push(newMovie);
    writeJSON('movies.json', movies);

    return res.status(201).json({
      success: true,
      message: 'Movie created',
      data: newMovie,
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// PUT /movies/:id
router.put('/:id', authMiddleware, (req, res) => {
  try {
    const movies = readJSON('movies.json');
    const index = movies.findIndex((m) => m.id === req.params.id);

    if (index === -1) {
      return res.status(404).json({ success: false, message: 'Movie not found' });
    }

    movies[index] = { ...movies[index], ...req.body, id: req.params.id };
    writeJSON('movies.json', movies);

    return res.status(200).json({
      success: true,
      message: 'Movie updated',
      data: movies[index],
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// DELETE /movies/:id
router.delete('/:id', authMiddleware, (req, res) => {
  try {
    const movies = readJSON('movies.json');
    const index = movies.findIndex((m) => m.id === req.params.id);

    if (index === -1) {
      return res.status(404).json({ success: false, message: 'Movie not found' });
    }

    const deleted = movies.splice(index, 1);
    writeJSON('movies.json', movies);

    return res.status(200).json({
      success: true,
      message: 'Movie deleted',
      data: deleted[0],
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

module.exports = router;
