SET allow_experimental_vector_similarity_index = 1;

CREATE TABLE demo.vector_items
(
    id UInt32,
    category_id UInt8,
    category LowCardinality(String),
    label String,
    embedding Array(Float32),
    CONSTRAINT embedding_dimension CHECK length(embedding) = 32,
    INDEX embedding_hnsw embedding
        TYPE vector_similarity('hnsw', 'L2Distance', 32, 'f32', 64, 512)
)
ENGINE = MergeTree
ORDER BY id
SETTINGS index_granularity = 256;

INSERT INTO demo.vector_items
SELECT
    toUInt32(number) AS id,
    toUInt8(intDiv(number, 16384)) AS category_id,
    arrayElement(
        [
            'analytics',
            'databases',
            'development',
            'finance',
            'science',
            'security',
            'systems',
            'visualization'
        ],
        category_id + 1
    ) AS category,
    concat(category, '-', leftPad(toString(number % 16384), 5, '0')) AS label,
    arrayMap(
        dimension -> toFloat32(
            if(dimension = category_id, 10.0, 0.0)
            + ((number * (dimension * 2 + 1)) % 65521) / 6552100.0
        ),
        range(32)
    ) AS embedding
FROM numbers(131072);

ALTER TABLE demo.vector_items
    MATERIALIZE INDEX embedding_hnsw
    SETTINGS mutations_sync = 2;
