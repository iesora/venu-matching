import React, { useState, useCallback } from "react";
import Cropper from "react-easy-crop";
import { Area } from "react-easy-crop";
import { Modal } from "antd";
import { Slider } from "antd";
import { Button } from "antd";
import { anBlue } from "@/utils/colors";

interface CropModalProps {
  isOpen: boolean;
  imgSrc: string;
  onClose: () => void;
  setCroppedImgSrc: (croppedImgSrc: string | undefined) => void;
  zoom: number;
  setZoom: (minZoom: number) => void;
  crop: { x: number; y: number };
  setCrop: (crop: { x: number; y: number }) => void;
  aspect: number;
}

const CropModal: React.FC<CropModalProps> = ({
  isOpen,
  onClose,
  imgSrc,
  setCroppedImgSrc,
  setZoom,
  crop,
  setCrop,
  zoom,
  aspect,
}) => {
  const onCropComplete = (
    croppedArea: any,
    croppedAreaPixels: React.SetStateAction<Area | undefined>
  ) => {
    setCroppedAreaPixels(croppedAreaPixels);
  };

  /** 画像拡大縮小の最小値 */

  /** 切り取る領域の情報 */

  /** 切り取る領域の情報 */
  const [croppedAreaPixels, setCroppedAreaPixels] = useState<Area>();

  const createImage = (url: string): Promise<HTMLImageElement> =>
    new Promise((resolve, reject) => {
      const image = new Image();
      image.addEventListener("load", () => resolve(image));
      image.addEventListener("error", (error) => reject(error));
      // CodeSandboxでCORSエラーを回避するために必要
      image.setAttribute("crossOrigin", "anonymous");
      image.src = url;
    });

  /**
   * 画像トリミングを行い新たな画像urlを作成
   */
  async function getCroppedImg(
    imageSrc: string,
    pixelCrop: Area
  ): Promise<string> {
    const image = await createImage(imageSrc);
    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");

    if (!ctx) {
      return "";
    }

    // canvasサイズを設定
    canvas.width = image.width;
    canvas.height = image.height;

    // canvas上に画像を描画
    ctx.drawImage(image, 0, 0);

    // トリミング後の画像を抽出
    const data = ctx.getImageData(
      pixelCrop.x,
      pixelCrop.y,
      pixelCrop.width,
      pixelCrop.height
    );

    // canvasのサイズ指定(切り取り後の画像サイズに更新)
    canvas.width = pixelCrop.width;
    canvas.height = pixelCrop.height;

    // 抽出した画像データをcanvasの左隅に貼り付け
    ctx.putImageData(data, 0, 0);

    // canvasを画像に変換
    return new Promise((resolve, reject) => {
      canvas.toBlob((file) => {
        if (file !== null) resolve(URL.createObjectURL(file));
      }, "image/jpeg");
    });
  }

  const showCroppedImage = useCallback(async () => {
    if (!croppedAreaPixels) return;
    try {
      const croppedImage = await getCroppedImg(imgSrc, croppedAreaPixels);

      setCroppedImgSrc(croppedImage);
    } catch (e) {
      console.error(e);
    }
    onClose();
  }, [croppedAreaPixels, getCroppedImg, imgSrc, onClose, setCroppedImgSrc]);

  const onChange = (value: number | number[]) => {
    setZoom(value as number);
  };

  const onChangeComplete = (area: Area, areaPixels: Area) => {
    setCroppedAreaPixels(areaPixels);
  };

  return (
    <Modal
      open={isOpen}
      width={1000}
      onOk={() => {
        showCroppedImage();
      }}
      footer={<div></div>}
    >
      {/**
      <input type="file" onChange={onFileChange} />
      */}
      <div style={{ position: "relative", width: "100%", height: "400px" }}>
        <Cropper
          image={imgSrc}
          crop={crop}
          zoom={zoom}
          aspect={aspect}
          onCropChange={setCrop}
          onCropComplete={onCropComplete}
          onZoomChange={setZoom}
        />
      </div>
      <div
        style={{
          position: "relative",
          width: "100%",
          height: "80px",
          padding: "20px",
        }}
      >
        <Slider
          min={1}
          max={3}
          value={zoom}
          step={0.1}
          onChange={(e) => {
            setZoom(e as number);
          }}
        />
        <div
          style={{
            display: "flex",
            justifyContent: "center",
          }}
        >
          <Button
            style={{
              height: "40px",
              marginRight: "20px",
            }}
            onClick={() => {
              onClose();
            }}
          >
            閉じる
          </Button>
          <Button
            type="primary"
            style={{
              height: "40px",
              backgroundColor: anBlue,
              borderColor: anBlue,
            }}
            onClick={() => {
              showCroppedImage();
            }}
          >
            切り抜く
          </Button>
        </div>
      </div>
    </Modal>
  );
};

export default CropModal;
