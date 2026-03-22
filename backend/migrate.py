"""Run database migrations against DATABASE_URL."""
import asyncio
import os
from pathlib import Path

import asyncpg


async def run():
    url = os.environ.get("DATABASE_URL", "postgresql://verazoi:verazoi@localhost:5432/verazoi")
    conn = await asyncpg.connect(url)

    migrations_dir = Path(__file__).parent / "migrations"
    for sql_file in sorted(migrations_dir.glob("*.sql")):
        print(f"Running {sql_file.name}...")
        sql = sql_file.read_text()
        try:
            await conn.execute(sql)
        except (asyncpg.exceptions.DuplicateTableError, asyncpg.exceptions.DuplicateObjectError) as e:
            print(f"  skipped ({e.__class__.__name__})")
        except Exception as e:
            print(f"  FAILED: {e}")
            await conn.close()
            raise

    await conn.close()
    print("Migrations complete.")


if __name__ == "__main__":
    asyncio.run(run())
