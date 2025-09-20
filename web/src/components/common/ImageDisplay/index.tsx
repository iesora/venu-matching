import { useEffect, useState } from "react";
import React from "react";
import axios from "axios";
import { baseURL } from "../../../utils/url";

interface ImageDisplayProps {
  fileName: string;
  alt: string;
  width?: string;
  height?: string;
}

const ImageDisplay: React.FC<ImageDisplayProps> = ({
  fileName,
  alt,
  width,
  height,
}) => {
  const [imageUrl, setImageUrl] = useState(null);

  useEffect(() => {
    async function fetchSignedUrl() {
      const res = await axios.get(
        `${baseURL}/storage/generate-signed-url?bucketName=integrated-management&fileName=${fileName}`
      );
      const data = await res.data;
      setImageUrl(data);
    }

    fetchSignedUrl();
  }, [fileName]);

  return (
    <div>
      {imageUrl ? (
        <img
          src={imageUrl}
          alt={alt}
          width={width}
          height={height}
          onError={(e) => {
            // レイアウトを保持するために透明な画像をエンコード、挿入
            /*
            e.currentTarget.src =
              "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==";
            e.currentTarget.alt = "";
            */
          }}
        />
      ) : (
        <p>Loading...</p>
      )}
    </div>
  );
};

export default ImageDisplay;
