"""Simple loader for sample company data."""

def load_company_data(filepath: str = "sample_company_data.txt") -> str:
    """Load and return the company data text."""
    with open(filepath, "r") as f:
        text = f.read().strip()
    return text


def print_info(text: str) -> None:
    """Print basic info about the text."""
    lines = text.split("\n")
    words = text.split()
    print(f"Characters: {len(text)}")
    print(f"Lines: {len(lines)}")
    print(f"Words: {len(words)}")
    print(f"Preview: {text[:100]}...")


if __name__ == "__main__":
    data = load_company_data()
    print_info(data)
