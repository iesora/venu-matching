import React, { useEffect } from "react";
import {
  Modal,
  Form,
  Input,
  InputNumber,
  Button,
  Upload,
  message,
  Space,
  Row,
  Col,
  notification,
} from "antd";
import { PlusOutlined, EnvironmentOutlined } from "@ant-design/icons";
import {
  useAPIPostVenue,
  CreateVenueRequest,
} from "@/hook/api/venue/useAPICreateVenue";
import {
  useAPIUpdateVenue,
  UpdateVenueRequest,
} from "@/hook/api/venue/useAPIUpdateVenue";
import { Venue } from "@/type";
import { anBlue, themeColor } from "@/utils/colors";

interface VenueModalProps {
  visible: boolean;
  venue?: Venue | null; // nullの場合は新規登録
  onCancel: () => void;
  onSuccess: () => void;
}

const VenueModal: React.FC<VenueModalProps> = ({
  visible,
  venue,
  onCancel,
  onSuccess,
}) => {
  const [form] = Form.useForm();
  const { mutate: mutateCreateVenue } = useAPIPostVenue({
    onSuccess: () => {
      notification.success({
        message: "会場を登録しました",
      });
      onSuccess();
    },
  });
  const { mutate: mutateUpdateVenue } = useAPIUpdateVenue({
    onSuccess: () => {
      notification.success({
        message: "会場を更新しました",
      });
      onSuccess();
    },
  });

  const isEdit = !!venue;

  useEffect(() => {
    if (visible) {
      if (venue) {
        form.setFieldsValue({
          name: venue.name,
          address: venue.address,
          tel: venue.tel,
          description: venue.description,
          capacity: venue.capacity,
          facilities: venue.facilities,
          availableTime: venue.availableTime,
          imageUrl: venue.imageUrl,
          latitude: venue.latitude,
          longitude: venue.longitude,
        });
      } else {
        form.resetFields();
      }
    }
  }, [visible, venue, form]);

  const handleSubmit = async (values: any) => {
    if (isEdit && venue) {
      mutateUpdateVenue({
        id: venue.id.toString(),
        data: values,
      });
    } else {
      mutateCreateVenue(values);
    }
  };

  const handleCancel = () => {
    form.resetFields();
    onCancel();
  };

  return (
    <Modal
      //   style={{ backgroundColor: themeColor }}
      title={isEdit ? "会場編集" : "会場登録"}
      open={visible}
      onCancel={handleCancel}
      footer={null}
      width={800}
      destroyOnClose
    >
      <Form
        // style={{ backgroundColor: themeColor }}
        form={form}
        layout="vertical"
        onFinish={handleSubmit}
        autoComplete="off"
      >
        <Form.Item
          label="会場画像"
          name="imageUrl"
          style={{ textAlign: "center" }}
        >
          <div
            style={{
              display: "flex",
              justifyContent: "center",
              marginBottom: "16px",
            }}
          >
            {venue?.imageUrl ? (
              <img
                src={venue.imageUrl}
                alt="会場画像"
                style={{
                  width: "200px",
                  height: "150px",
                  objectFit: "cover",
                  borderRadius: "8px",
                }}
              />
            ) : (
              <div
                style={{
                  width: "200px",
                  height: "150px",
                  backgroundColor: "#f5f5f5",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  borderRadius: "8px",
                  color: "#999",
                }}
              >
                <EnvironmentOutlined style={{ fontSize: "48px" }} />
              </div>
            )}
          </div>
          <Upload
            name="image"
            listType="picture-card"
            className="image-uploader"
            showUploadList={false}
            beforeUpload={() => false} // アップロードを無効化（実装は後で追加）
          >
            <div>
              <PlusOutlined />
              <div style={{ marginTop: 8 }}>画像をアップロード</div>
            </div>
          </Upload>
        </Form.Item>

        <Row gutter={16}>
          <Col span={24}>
            <Form.Item
              label="会場名"
              name="name"
              rules={[
                { required: true, message: "会場名を入力してください" },
                { max: 100, message: "100文字以内で入力してください" },
              ]}
            >
              <Input placeholder="会場名を入力してください" />
            </Form.Item>
          </Col>
        </Row>
        <Row gutter={16}>
          <Col span={24}>
            <Form.Item
              label="住所"
              name="address"
              rules={[{ max: 500, message: "500文字以内で入力してください" }]}
            >
              <Input placeholder="住所を入力してください" />
            </Form.Item>
          </Col>
        </Row>

        <Row gutter={16}>
          <Col span={12}>
            <Form.Item
              label="電話番号"
              name="tel"
              rules={[{ max: 20, message: "20文字以内で入力してください" }]}
            >
              <Input placeholder="電話番号を入力してください" />
            </Form.Item>
          </Col>
          <Col span={12}>
            <Form.Item
              label="定員"
              name="capacity"
              rules={[
                {
                  type: "number",
                  min: 1,
                  message: "1以上の数値を入力してください",
                },
              ]}
            >
              <InputNumber
                placeholder="定員を入力してください"
                style={{ width: "100%" }}
                min={1}
                max={500000}
              />
            </Form.Item>
          </Col>
        </Row>
        <Row gutter={16}>
          <Col span={12}>
            <Form.Item
              label="緯度"
              name="latitude"
              rules={[
                {
                  type: "number",
                  min: -90,
                  max: 90,
                  message: "-90から90の間で入力してください",
                },
              ]}
            >
              <InputNumber
                placeholder="緯度を入力してください"
                style={{ width: "100%" }}
                min={-90}
                max={90}
                step={0.000001}
                precision={8}
              />
            </Form.Item>
          </Col>
          <Col span={12}>
            <Form.Item
              label="経度"
              name="longitude"
              rules={[
                {
                  type: "number",
                  min: -180,
                  max: 180,
                  message: "-180から180の間で入力してください",
                },
              ]}
            >
              <InputNumber
                placeholder="経度を入力してください"
                style={{ width: "100%" }}
                min={-180}
                max={180}
                step={0.000001}
                precision={8}
              />
            </Form.Item>
          </Col>
        </Row>

        <Form.Item
          label="説明"
          name="description"
          rules={[{ max: 1000, message: "1000文字以内で入力してください" }]}
        >
          <Input.TextArea
            rows={4}
            placeholder="会場の説明を入力してください"
            showCount
            maxLength={1000}
          />
        </Form.Item>
        <Form.Item
          label="設備情報"
          name="facilities"
          rules={[{ max: 1000, message: "1000文字以内で入力してください" }]}
        >
          <Input.TextArea
            rows={4}
            placeholder="会場の設備情報を入力してください"
            showCount
            maxLength={1000}
          />
        </Form.Item>
        <Form.Item
          label="利用可能時間"
          name="availableTime"
          rules={[{ max: 1000, message: "1000文字以内で入力してください" }]}
        >
          <Input.TextArea
            rows={4}
            placeholder="10:00-20:00"
            showCount
            maxLength={1000}
          />
        </Form.Item>

        <Form.Item style={{ marginBottom: 0, textAlign: "right" }}>
          <Space>
            <Button onClick={handleCancel}>キャンセル</Button>
            <Button
              type="primary"
              htmlType="submit"
              style={{ backgroundColor: anBlue, borderColor: anBlue }}
              //   loading={
              //     mutateCreateVenue.isLoading || mutateUpdateVenue.isLoading
              //   }
            >
              {isEdit ? "更新" : "登録"}
            </Button>
          </Space>
        </Form.Item>
      </Form>
    </Modal>
  );
};

export default VenueModal;
