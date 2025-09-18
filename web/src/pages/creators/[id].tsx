import React, { useState } from "react";
import { useRouter } from "next/router";
import {
  Card,
  Spin,
  Alert,
  Typography,
  Avatar,
  Button,
  Row,
  Col,
  Divider,
  Space,
  notification,
} from "antd";
import {
  UserOutlined,
  CalendarOutlined,
  ArrowLeftOutlined,
  EditOutlined,
  MessageOutlined,
  PhoneOutlined,
  MailOutlined,
  DeleteOutlined,
} from "@ant-design/icons";
import { useAPIGetCreatorById } from "@/hook/api/creator/useAPIGetCreatorById";
import PageLayout from "@/components/common/PageLayout";
import CreatorModal from "@/components/Modal/CreatorModal";
import { useAPIAuthenticate } from "@/hook/api/auth/useAPIAuthenticate";
import { User } from "@/type";
import { anBlue } from "@/utils/colors";
import { useEffect } from "react";
import { useAPIDeleteCreator } from "@/hook/api/creator/useAPIDeleteCreator";
const { Title, Text, Paragraph } = Typography;

const CreatorDetailPage: React.FC = () => {
  const router = useRouter();
  const { id } = router.query;
  const [user, setUser] = useState<User | undefined>(undefined);
  const { mutate: mutateAuthenticate } = useAPIAuthenticate({
    onSuccess: (user) => {
      setUser(user);
    },
  });
  const { mutate: mutateDeleteCreator } = useAPIDeleteCreator({
    onSuccess: () => {
      router.push("/creators");
      notification.success({
        message: "クリエイターを削除しました",
      });
    },
    onError: () => {
      notification.error({
        message: "クリエイターを削除に失敗しました",
      });
    },
  });

  const {
    data: creator,
    isLoading,
    error,
    refetch,
  } = useAPIGetCreatorById(id as string);
  const [modalVisible, setModalVisible] = useState(false);

  useEffect(() => {
    mutateAuthenticate();
  }, []);

  if (isLoading) {
    return (
      <PageLayout>
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            height: "50vh",
          }}
        >
          <Spin size="large" />
        </div>
      </PageLayout>
    );
  }

  if (error) {
    return (
      <PageLayout>
        <Alert
          message="エラー"
          description={error.message}
          type="error"
          showIcon
          action={
            <Button size="small" danger onClick={() => refetch()}>
              再試行
            </Button>
          }
        />
      </PageLayout>
    );
  }

  if (!creator) {
    return (
      <PageLayout>
        <Alert
          message="クリエイターが見つかりません"
          description="指定されたクリエイターが存在しないか、削除された可能性があります。"
          type="warning"
          showIcon
        />
      </PageLayout>
    );
  }

  return (
    <PageLayout>
      <div style={{ padding: "24px" }}>
        {/* ヘッダー部分 */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: "24px",
          }}
        >
          <Button
            icon={<ArrowLeftOutlined />}
            onClick={() => router.back()}
            style={{ marginRight: "16px" }}
          >
            戻る
          </Button>
          <Title level={2} style={{ margin: 0, flex: 1 }}>
            {creator.name}
          </Title>
          {creator.user.id === user?.id && (
            <div style={{ display: "flex", gap: "8px" }}>
              <Button
                type="primary"
                icon={<EditOutlined />}
                style={{ backgroundColor: anBlue, borderColor: anBlue }}
                onClick={() => setModalVisible(true)}
              >
                編集
              </Button>
              <Button
                type="primary"
                danger
                icon={<DeleteOutlined />}
                onClick={() => mutateDeleteCreator(creator.id)}
              >
                削除
              </Button>
            </div>
          )}
        </div>

        <Row gutter={[24, 24]}>
          {/* プロフィール画像とメイン情報 */}
          <Col xs={24} lg={16}>
            <Card>
              {/* プロフィール画像 */}
              <div style={{ textAlign: "center", marginBottom: "32px" }}>
                {creator.imageUrl ? (
                  <Avatar
                    size={200}
                    src={creator.imageUrl}
                    icon={<UserOutlined />}
                  />
                ) : (
                  <Avatar
                    size={200}
                    icon={<UserOutlined />}
                    style={{
                      backgroundColor: "#f0f0f0",
                      color: "#999",
                      fontSize: "80px",
                    }}
                  />
                )}
              </div>

              <div>
                <Title level={3}>プロフィール</Title>
                <Space
                  direction="vertical"
                  size="middle"
                  style={{ width: "100%" }}
                >
                  <div>
                    <Text strong>クリエイター名:</Text>
                    <Text style={{ marginLeft: "8px", fontSize: "18px" }}>
                      {creator.name}
                    </Text>
                  </div>

                  {creator.description && (
                    <div>
                      <Text strong>自己紹介:</Text>
                      <Paragraph style={{ marginTop: "8px", marginBottom: 0 }}>
                        {creator.description}
                      </Paragraph>
                    </div>
                  )}

                  <Divider />

                  {/* 統計情報 */}
                  <Row gutter={[16, 16]}>
                    <Col xs={24} sm={8}>
                      <Card size="small">
                        <div style={{ textAlign: "center" }}>
                          <UserOutlined
                            style={{
                              fontSize: "24px",
                              color: "#1890ff",
                              marginBottom: "8px",
                            }}
                          />
                          <div>
                            <Text strong>フォロワー</Text>
                            <div>
                              <Text
                                style={{ fontSize: "20px", fontWeight: "bold" }}
                              >
                                1,234
                              </Text>
                            </div>
                          </div>
                        </div>
                      </Card>
                    </Col>
                    <Col xs={24} sm={8}>
                      <Card size="small">
                        <div style={{ textAlign: "center" }}>
                          <CalendarOutlined
                            style={{
                              fontSize: "24px",
                              color: "#52c41a",
                              marginBottom: "8px",
                            }}
                          />
                          <div>
                            <Text strong>イベント数</Text>
                            <div>
                              <Text
                                style={{ fontSize: "20px", fontWeight: "bold" }}
                              >
                                45
                              </Text>
                            </div>
                          </div>
                        </div>
                      </Card>
                    </Col>
                    <Col xs={24} sm={8}>
                      <Card size="small">
                        <div style={{ textAlign: "center" }}>
                          <MessageOutlined
                            style={{
                              fontSize: "24px",
                              color: "#fa8c16",
                              marginBottom: "8px",
                            }}
                          />
                          <div>
                            <Text strong>レビュー</Text>
                            <div>
                              <Text
                                style={{ fontSize: "20px", fontWeight: "bold" }}
                              >
                                4.8
                              </Text>
                            </div>
                          </div>
                        </div>
                      </Card>
                    </Col>
                  </Row>
                </Space>
              </div>
            </Card>
          </Col>

          {/* サイドバー情報 */}
          <Col xs={24} lg={8}>
            <Space direction="vertical" size="middle" style={{ width: "100%" }}>
              {/* 基本情報カード */}
              <Card title="基本情報" size="small">
                <Space
                  direction="vertical"
                  size="small"
                  style={{ width: "100%" }}
                >
                  <div>
                    <Text type="secondary">クリエイターID:</Text>
                    <Text style={{ marginLeft: "8px" }}>{creator.id}</Text>
                  </div>
                  <div>
                    <Text type="secondary">メールアドレス:</Text>
                    <Text style={{ marginLeft: "8px" }}>{creator.email}</Text>
                  </div>
                  <div>
                    <Text type="secondary">電話番号:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {creator.phoneNumber}
                    </Text>
                  </div>
                  <div>
                    <Text type="secondary">ウェブサイト:</Text>
                    <Text style={{ marginLeft: "8px" }}>{creator.website}</Text>
                  </div>
                  <div>
                    <Text type="secondary">SNSハンドル:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {creator.socialMediaHandle}
                    </Text>
                  </div>
                  <div>
                    <Text type="secondary">登録日:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {new Date(creator.createdAt).toLocaleDateString("ja-JP")}
                    </Text>
                  </div>
                  <div>
                    <Text type="secondary">最終更新:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {new Date(creator.updatedAt).toLocaleDateString("ja-JP")}
                    </Text>
                  </div>
                </Space>
              </Card>

              {/* アクションボタン */}
              <Card title="アクション" size="small">
                <Space
                  direction="vertical"
                  size="small"
                  style={{ width: "100%" }}
                >
                  <Button
                    type="primary"
                    block
                    icon={<CalendarOutlined />}
                    style={{ backgroundColor: anBlue, borderColor: anBlue }}
                  >
                    イベントを見る
                  </Button>
                  <Button block icon={<EditOutlined />}>
                    編集する
                  </Button>
                  <Button danger block>
                    削除する
                  </Button>
                </Space>
              </Card>
              {/* 最近の活動 */}
              {/* <Card title="最近の活動" size="small">
                <Space
                  direction="vertical"
                  size="small"
                  style={{ width: "100%" }}
                >
                  <div>
                    <Text strong>最新イベント:</Text>
                    <Text style={{ marginLeft: "8px" }}>ライブコンサート</Text>
                  </div>
                  <div>
                    <Text strong>開催日:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {new Date().toLocaleDateString("ja-JP")}
                    </Text>
                  </div>
                  <div>
                    <Text strong>場所:</Text>
                    <Text style={{ marginLeft: "8px" }}>東京ドーム</Text>
                  </div>
                </Space>
              </Card> */}
            </Space>
          </Col>
        </Row>

        <CreatorModal
          visible={modalVisible}
          onCancel={() => setModalVisible(false)}
          onSuccess={() => {
            refetch();
            setModalVisible(false);
          }}
          creator={creator}
        />
      </div>
    </PageLayout>
  );
};

export default CreatorDetailPage;
