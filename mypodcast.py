""" Module to generate an RSS feed for your podcast. """

import datetime
import os
import pathlib
import xml.etree.ElementTree as ET

from dotenv import load_dotenv


def generate_podcast_rss(
    local_podcast_title,
    local_podcast_description,
    local_podcast_link,
    local_podcasts_directory,
    local_output_file,
) -> None:
    """
    Generate an RSS feed for your podcast.
    Args:
        local_podcast_title: The title of the podcast.
        local_podcast_description: A description of the podcast.
        local_podcast_link: The URL of the podcast website.
        local_podcasts_directory: The path to the directory containing the podcast files.
        local_output_file: The path to the output RSS feed file.
    """

    root = ET.Element("rss")
    root.set("version", "2.0")
    channel = ET.SubElement(root, "channel")
    ET.SubElement(channel, "title").text = local_podcast_title
    ET.SubElement(channel, "description").text = local_podcast_description
    ET.SubElement(channel, "link").text = local_podcast_link
    ET.SubElement(channel, "language").text = "de-DE"

    for file in pathlib.Path(local_podcasts_directory).glob("*.mp3"):
        # file_path = file.absolute()
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
        enclosure.set("type", "audio/mp3")

    tree = ET.ElementTree(root)
    tree.write(local_output_file, encoding="unicode", xml_declaration=True)


load_dotenv()
podcast_title = os.getenv("PODCAST_TITLE")
podcast_description = os.getenv("PODCAST_DESCRIPTION")
podcast_link = os.getenv("PODCAST_LINK")
podcasts_directory = os.getenv("PODCASTS_DIR")
output_file = pathlib.Path(podcasts_directory) / "podcast.xml"

generate_podcast_rss(
    podcast_title, podcast_description, podcast_link, podcasts_directory, output_file
)
