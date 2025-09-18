import React, { useEffect } from "react";
import {
  Modal,
  Form,
  Input,
  Button,
  Upload,
  Avatar,
  message,
  Space,
  notification,
} from "antd";
import { PlusOutlined, UserOutlined } from "@ant-design/icons";
import {
  useAPICreateCreator,
  CreateCreatorRequest,
} from "@/hook/api/creator/useAPICreateCreator";
import {
  useAPIUpdateCreator,
  UpdateCreatorRequest,
} from "@/hook/api/creator/useAPIUpdateCreator";
import { Creator } from "@/type";
import { anBlue } from "@/utils/colors";

interface CreatorModalProps {
  visible: boolean;
  onCancel: () => void;
  onSuccess: () => void;
  creator?: Creator | null; // nullの場合は新規作成
}

const CreatorModal: React.FC<CreatorModalProps> = ({
  visible,
  onCancel,
  onSuccess,
  creator,
}) => {
  const [form] = Form.useForm();
  const { mutate: mutateCreateCreator, isLoading: isLoadingCreate } =
    useAPICreateCreator({
      onSuccess: () => {
        notification.success({
          message: "クリエイターを作成しました",
        });
        onSuccess();
        form.resetFields();
        onCancel();
      },
      onError: (error) => {
        notification.error({
          message: "クリエイターを作成に失敗しました",
        });
      },
    });
  const { mutate: mutateUpdateCreator, isLoading: isLoadingUpdate } =
    useAPIUpdateCreator({
      onSuccess: () => {
        notification.success({
          message: "クリエイターを更新しました",
        });
        onSuccess();
        form.resetFields();
        onCancel();
      },
      onError: (error) => {
        notification.error({
          message: "クリエイターを更新に失敗しました",
        });
      },
    });

  const isEdit = !!creator;

  useEffect(() => {
    if (visible) {
      if (creator) {
        form.setFieldsValue({
          name: creator.name,
          description: creator.description,
          email: creator.email,
          website: creator.website,
          phoneNumber: creator.phoneNumber,
          socialMediaHandle: creator.socialMediaHandle,
          imageUrl: creator.imageUrl,
        });
      } else {
        form.resetFields();
      }
    }
  }, [visible, creator, form]);

  const handleSubmit = async (values: any) => {
    if (isEdit && creator) {
      mutateUpdateCreator({
        id: creator.id.toString(),
        data: values,
      });
    } else {
      mutateCreateCreator(values);
    }
  };

  const handleCancel = () => {
    form.resetFields();
    onCancel();
  };

  return (
    <Modal
      title={isEdit ? "クリエイター編集" : "クリエイター作成"}
      open={visible}
      onCancel={handleCancel}
      footer={null}
      width={600}
      destroyOnClose
    >
      <Form
        form={form}
        layout="vertical"
        onFinish={handleSubmit}
        autoComplete="off"
      >
        <Form.Item
          label="プロフィール画像"
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
            <Avatar
              size={100}
              icon={<UserOutlined />}
              src={creator?.imageUrl}
              style={{ backgroundColor: "#f0f0f0" }}
            />
          </div>
          <Upload
            name="avatar"
            listType="picture-card"
            className="avatar-uploader"
            showUploadList={false}
            beforeUpload={() => false} // アップロードを無効化（実装は後で追加）
          >
            <div>
              <PlusOutlined />
              <div style={{ marginTop: 8 }}>画像をアップロード</div>
            </div>
          </Upload>
        </Form.Item>

        <Form.Item
          label="クリエイター名"
          name="name"
          rules={[
            { required: true, message: "クリエイター名を入力してください" },
            { max: 100, message: "100文字以内で入力してください" },
          ]}
        >
          <Input placeholder="クリエイター名を入力してください" />
        </Form.Item>

        <Form.Item
          label="説明"
          name="description"
          rules={[{ max: 500, message: "500文字以内で入力してください" }]}
        >
          <Input.TextArea
            rows={4}
            placeholder="クリエイターの説明を入力してください"
            showCount
            maxLength={500}
          />
        </Form.Item>

        <Form.Item
          label="メールアドレス"
          name="email"
          rules={[
            {
              type: "email",
              message: "正しいメールアドレスを入力してください",
            },
          ]}
        >
          <Input placeholder="メールアドレスを入力してください" />
        </Form.Item>

        <Form.Item
          label="ウェブサイト"
          name="website"
          rules={[{ type: "url", message: "正しいURLを入力してください" }]}
        >
          <Input placeholder="ウェブサイトのURLを入力してください" />
        </Form.Item>

        <Form.Item label="電話番号" name="phoneNumber">
          <Input placeholder="電話番号を入力してください" />
        </Form.Item>

        <Form.Item label="SNSハンドル" name="socialMediaHandle">
          <Input placeholder="SNSハンドルを入力してください" />
        </Form.Item>

        <Form.Item style={{ marginBottom: 0, textAlign: "right" }}>
          <Space>
            <Button onClick={handleCancel}>キャンセル</Button>
            <Button
              type="primary"
              htmlType="submit"
              loading={isLoadingCreate || isLoadingUpdate}
              style={{ backgroundColor: anBlue, borderColor: anBlue }}
            >
              {isEdit ? "更新" : "作成"}
            </Button>
          </Space>
        </Form.Item>
      </Form>
    </Modal>
  );
};

export default CreatorModal;
