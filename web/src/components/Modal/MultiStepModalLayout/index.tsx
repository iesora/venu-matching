import React, { ReactNode } from "react";
import { Modal, Button, Tooltip } from "antd";
import { anBlue } from "@/utils/colors";

interface MultiStepModalLayoutProps {
  isOpen: boolean;
  handleClose: () => void;
  title: string;
  okText?: string;
  onOk?: () => void;
  handleBack?: () => void;
  currentStep: number;
  totalSteps: number;
  children: ReactNode;
  okButtonDisabled?: boolean;
}

const MultiStepModalLayout: React.FC<MultiStepModalLayoutProps> = ({
  isOpen,
  handleClose,
  title,
  okText,
  onOk,
  handleBack,
  currentStep,
  totalSteps,
  children,
  okButtonDisabled,
}) => {
  return (
    <Modal
      title={title}
      open={isOpen}
      onCancel={handleClose}
      footer={null}
      width={1000}
    >
      <div
        style={{ marginBottom: "8px", borderTop: "1px solid lightgray" }}
      ></div>
      <div
        style={{ display: "flex", flexDirection: "column", height: "600px" }}
      >
        <div style={{ flex: 1, overflowY: "auto", paddingRight: "8px" }}>
          {children}
        </div>
        <div
          style={{
            padding: "10px",
          }}
        >
          <div style={{ display: "flex", alignItems: "center" }}>
            <div style={{ flex: 1 }} />
            <div
              style={{ flex: 1, display: "flex", justifyContent: "flex-end" }}
            >
              {currentStep > 1 && (
                <Button onClick={handleBack} style={{ marginLeft: "8px" }}>
                  戻る
                </Button>
              )}
              {okButtonDisabled ? (
                <Tooltip
                  title="項目を1つ以上選択してください"
                  placement="top"
                  overlayInnerStyle={{ fontSize: "11px" }}
                >
                  <span>
                    <Button
                      type="primary"
                      onClick={onOk}
                      disabled
                      style={{
                        marginLeft: "8px",
                        backgroundColor: anBlue,
                        borderColor: anBlue,
                      }}
                    >
                      {okText || "完了"}
                    </Button>
                  </span>
                </Tooltip>
              ) : (
                <Button
                  type="primary"
                  onClick={onOk}
                  style={{
                    marginLeft: "8px",
                    backgroundColor: anBlue,
                    borderColor: anBlue,
                  }}
                >
                  {okText || "完了"}
                </Button>
              )}
            </div>
          </div>
        </div>
      </div>
    </Modal>
  );
};

export default MultiStepModalLayout;
