import os
import dotenv
import datetime

# import feedparser
import pathlib
import xml.etree.ElementTree as ET

# def generate_podcast_rss(podcast_title, podcast_description, podcast_link, output_file, podcasts_directory):
#     """
#     Generates a podcast RSS feed with Opus files from a specified directory.

#     Args:
#         podcast_title: The title of the podcast.
#         podcast_description: The description of the podcast.
#         podcast_link: The link to the podcast website.
#         output_file: The filename for the generated RSS feed.
#         podcasts_directory: The directory containing the Opus files.
#     """

#     feed = feedparser.FeedParserDict()
#     feed['feed'] = {}
#     feed['feed']['title'] = podcast_title
#     feed['feed']['description'] = podcast_description
#     feed['feed']['link'] = podcast_link
#     feed['feed']['language'] = 'de-DE'  # Adjust the language as needed
#     feed['entries'] = []

#     for file in pathlib.Path(podcasts_directory).glob('*.opus'):
#         file_path = file.absolute()
#         file_size = file.stat().st_size
#         file_url = f"{podcast_link}/{file.name}"  # Replace with your actual server URL

#         entry = {}
#         entry['title'] = file.stem  # Remove the .opus extension
#         entry['description'] = f"Episode {file.stem}"  # Customize the description as needed
#         entry['link'] = file_url
#         entry['guid'] = file_url
#         entry['pubDate'] = datetime.datetime.now(datetime.timezone.utc).strftime('%a, %d %b %Y %H:%M:%S %z')
#         entry['enclosures'] = [{'url': file_url, 'length': file_size, 'type': 'audio/opus'}]

#         feed['entries'].append(entry)

#     feedparser.serialize(feed, output_file)


def generate_podcast_rss(
    podcast_title, podcast_description, podcast_link, output_file, podcasts_directory
):
    # ... (rest of the function remains the same)

    root = ET.Element("rss")
    root.set("version", "2.0")
    channel = ET.SubElement(root, "channel")
    ET.SubElement(channel, "title").text = podcast_title
    ET.SubElement(channel, "description").text = podcast_description
    ET.SubElement(channel, "link").text = podcast_link
    ET.SubElement(channel, "language").text = "de-DE"

    for file in pathlib.Path(podcasts_directory).glob("*.opus"):
        file_path = file.absolute()
        file_size = file.stat().st_size
        file_url = f"{podcast_link}/{file.name}"  # Replace with your actual server URL

        item = ET.SubElement(channel, "item")
        ET.SubElement(item, "title").text = file.stem  # Remove the .opus extension
        ET.SubElement(item, "description").text = (
            f"Episode {file.stem}"  # Customize the description as needed
        )
        ET.SubElement(item, "link").text = file_url
        ET.SubElement(item, "guid").text = file_url
        ET.SubElement(item, "pubDate").text = datetime.datetime.now(
            datetime.timezone.utc
        ).strftime("%a, %d %b %Y %H:%M:%S %z")
        enclosure = ET.SubElement(item, "enclosure")
        enclosure.set("url", file_url)
        enclosure.set("length", str(file_size))
        enclosure.set("type", "audio/opus")

    tree = ET.ElementTree(root)
    tree.write(output_file)


dotenv.load_dotenv()
podcast_title = os.getenv("PODCAST_TITLE")
podcast_description = os.getenv("PODCAST_DESCRIPTION")
podcast_link = os.getenv("PODCAST_LINK")
podcasts_directory = os.getenv("PODCASTS_DIR")
output_file = pathlib.Path(podcasts_directory) / "podcast.xml"

generate_podcast_rss(
    podcast_title, podcast_description, podcast_link, output_file, podcasts_directory
)
