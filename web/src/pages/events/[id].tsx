import React, { useState, useEffect } from "react";
import { useRouter } from "next/router";
import {
  Card,
  Spin,
  Alert,
  Typography,
  Button,
  Row,
  Col,
  Divider,
  Space,
  Tag,
  Avatar,
} from "antd";
import {
  CalendarOutlined,
  EnvironmentOutlined,
  TeamOutlined,
  ArrowLeftOutlined,
  UserOutlined,
  ClockCircleOutlined,
  EditOutlined,
  DeleteOutlined,
} from "@ant-design/icons";
import { useAPIGetEventById } from "@/hook/api/event/useAPIGetEventById";
import PageLayout from "@/components/common/PageLayout";
import { useAPIAuthenticate } from "@/hook/api/auth/useAPIAuthenticate";
import { User } from "@/type";
import EventModal from "@/components/Modal/EventModal";

const { Title, Text, Paragraph } = Typography;

const EventDetailPage: React.FC = () => {
  const router = useRouter();
  const { id } = router.query;
  const {
    data: event,
    isLoading,
    error,
    refetch,
  } = useAPIGetEventById(id as string);
  const [user, setUser] = useState<User | undefined>(undefined);
  const { mutate: mutateAuthenticate } = useAPIAuthenticate({
    onSuccess: (user) => {
      setUser(user);
    },
  });
  const [modalVisible, setModalVisible] = useState(false);

  useEffect(() => {
    mutateAuthenticate();
  }, []);

  //イベントの開催済みかどうかのステータス
  const [scheduleStatus, setScheduleStatus] = useState<
    "today" | "past" | "future"
  >("future");
  useEffect(() => {
    if (event?.endDate) {
      const startDate = new Date(event.startDate);
      const endDate = new Date(event.endDate);
      const today = new Date();
      //今日の日付とイベント開催日の年月日を比較
      if (endDate.getFullYear() < today.getFullYear()) {
        // 終了日が今年より前
        setScheduleStatus("past");
      } else if (startDate.getFullYear() > today.getFullYear()) {
        // 開始日が今年より後
        setScheduleStatus("future");
      } else {
        // イベント期間が今年
        if (
          endDate.getFullYear() == today.getFullYear() &&
          endDate.getMonth() < today.getMonth()
        ) {
          // 終了日が今月より前
          setScheduleStatus("past");
        } else if (
          startDate.getFullYear() == today.getFullYear() &&
          startDate.getMonth() > today.getMonth()
        ) {
          // 開始日が今月より後
          setScheduleStatus("future");
        } else {
          //イベント期間が今月
          if (
            endDate.getFullYear() == today.getFullYear() &&
            endDate.getMonth() == today.getMonth() &&
            endDate.getDate() < today.getDate()
          ) {
            // 終了日が今日より前
            setScheduleStatus("past");
          } else if (
            startDate.getFullYear() == today.getFullYear() &&
            startDate.getMonth() == today.getMonth() &&
            startDate.getDate() > today.getDate()
          ) {
            // 開始日が今日より後
            setScheduleStatus("future");
          } else {
            // イベント期間が今日
            setScheduleStatus("today");
          }
        }
      }
    }
  }, [event]);

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

  if (!event) {
    return (
      <PageLayout>
        <Alert
          message="イベントが見つかりません"
          description="指定されたイベントが存在しないか、削除された可能性があります。"
          type="warning"
          showIcon
        />
      </PageLayout>
    );
  }

  const formatDate = (date: Date) => {
    return new Date(date).toLocaleDateString("ja-JP", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const formatDateOnly = (date: Date) => {
    return new Date(date).toLocaleDateString("ja-JP", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  const formatTimeOnly = (date: Date) => {
    return new Date(date).toLocaleTimeString("ja-JP", {
      hour: "2-digit",
      minute: "2-digit",
    });
  };

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
            {event.title}
          </Title>

          {event.venue.user.id === user?.id && (
            <div style={{ display: "flex", gap: "8px" }}>
              <Button
                type="primary"
                icon={<EditOutlined />}
                onClick={() => setModalVisible(true)}
              >
                編集
              </Button>
              <Button
                type="primary"
                danger
                icon={<DeleteOutlined />}
                // onClick={() => mutateDeleteEvent(event.id)}
              >
                削除
              </Button>
            </div>
          )}
        </div>

        <Row gutter={[24, 24]}>
          {/* メイン情報 */}
          <Col xs={24} lg={16}>
            <Card>
              {/* イベント画像エリア */}
              <div
                style={{
                  height: "400px",
                  backgroundColor: "#f5f5f5",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  borderRadius: "8px",
                  marginBottom: "24px",
                }}
              >
                <CalendarOutlined style={{ fontSize: "64px", color: "#ccc" }} />
              </div>

              <div>
                <Title level={3}>イベント詳細</Title>
                <Space
                  direction="vertical"
                  size="middle"
                  style={{ width: "100%" }}
                >
                  <div>
                    <Text strong>イベント名:</Text>
                    <Text style={{ marginLeft: "8px", fontSize: "18px" }}>
                      {event.title}
                    </Text>
                  </div>

                  {event.description && (
                    <div>
                      <Text strong>説明:</Text>
                      <Paragraph style={{ marginTop: "8px", marginBottom: 0 }}>
                        {event.description}
                      </Paragraph>
                    </div>
                  )}

                  <Divider />

                  {/* 開催情報 */}
                  <Row gutter={[16, 16]}>
                    <Col xs={24} sm={12}>
                      <Card size="small">
                        <div style={{ textAlign: "center" }}>
                          <CalendarOutlined
                            style={{
                              fontSize: "24px",
                              color: "#1890ff",
                              marginBottom: "8px",
                            }}
                          />
                          <div>
                            <Text strong>開催日</Text>
                            <div>
                              <Text
                                style={{
                                  fontSize: "16px",
                                  fontWeight: "bold",
                                }}
                              >
                                {formatDateOnly(event.startDate)}
                              </Text>
                            </div>
                          </div>
                        </div>
                      </Card>
                    </Col>
                    <Col xs={24} sm={12}>
                      <Card size="small">
                        <div style={{ textAlign: "center" }}>
                          <ClockCircleOutlined
                            style={{
                              fontSize: "24px",
                              color: "#52c41a",
                              marginBottom: "8px",
                            }}
                          />
                          <div>
                            <Text strong>開催時間</Text>
                            <div>
                              <Text
                                style={{
                                  fontSize: "16px",
                                  fontWeight: "bold",
                                }}
                              >
                                {formatTimeOnly(event.startDate)} -{" "}
                                {formatTimeOnly(event.endDate)}
                              </Text>
                            </div>
                          </div>
                        </div>
                      </Card>
                    </Col>
                  </Row>

                  <Divider />

                  {/* 会場情報 */}
                  <div>
                    <Title level={4}>会場情報</Title>
                    <Card size="small" style={{ marginTop: "12px" }}>
                      <div style={{ display: "flex", alignItems: "center" }}>
                        {event.venue.imageUrl ? (
                          <Avatar size={60} src={event.venue.imageUrl} />
                        ) : (
                          <Avatar size={60} icon={<EnvironmentOutlined />} />
                        )}
                        <div style={{ marginLeft: "16px", flex: 1 }}>
                          <Title level={5} style={{ margin: 0 }}>
                            {event.venue.name}
                          </Title>
                          <Text type="secondary">{event.venue.address}</Text>
                          {event.venue.capacity && (
                            <div style={{ marginTop: "4px" }}>
                              <Text type="secondary">
                                定員: {event.venue.capacity}人
                              </Text>
                            </div>
                          )}
                        </div>
                        <Button
                          type="link"
                          onClick={() =>
                            router.push(`/venues/${event.venue.id}`)
                          }
                        >
                          会場詳細を見る
                        </Button>
                      </div>
                    </Card>
                  </div>

                  <Divider />

                  {/* 参加クリエイター */}
                  <div>
                    <Title level={4}>参加クリエイター</Title>
                    {event.creatorEvents.length > 0 ? (
                      <Row gutter={[16, 16]} style={{ marginTop: "12px" }}>
                        {event.creatorEvents.map((creatorEvent) => (
                          <Col xs={24} sm={12} md={8} key={creatorEvent.id}>
                            <Card size="small" hoverable>
                              <div style={{ textAlign: "center" }}>
                                {creatorEvent.creator.imageUrl ? (
                                  <Avatar
                                    size={60}
                                    src={creatorEvent.creator.imageUrl}
                                    icon={<UserOutlined />}
                                  />
                                ) : (
                                  <Avatar
                                    size={60}
                                    icon={<UserOutlined />}
                                    style={{
                                      backgroundColor: "#f0f0f0",
                                      color: "#999",
                                    }}
                                  />
                                )}
                                <div style={{ marginTop: "8px" }}>
                                  <Text strong>
                                    {creatorEvent.creator.name}
                                  </Text>
                                  {creatorEvent.creator.description && (
                                    <div style={{ marginTop: "4px" }}>
                                      <Text
                                        type="secondary"
                                        style={{ fontSize: "12px" }}
                                      >
                                        {creatorEvent.creator.description
                                          .length > 50
                                          ? `${creatorEvent.creator.description.substring(
                                              0,
                                              50
                                            )}...`
                                          : creatorEvent.creator.description}
                                      </Text>
                                    </div>
                                  )}
                                </div>
                                <Button
                                  type="link"
                                  size="small"
                                  onClick={() =>
                                    router.push(
                                      `/creators/${creatorEvent.creator.id}`
                                    )
                                  }
                                >
                                  詳細を見る
                                </Button>
                              </div>
                            </Card>
                          </Col>
                        ))}
                      </Row>
                    ) : (
                      <div
                        style={{
                          textAlign: "center",
                          padding: "24px",
                          backgroundColor: "#f5f5f5",
                          borderRadius: "8px",
                          marginTop: "12px",
                        }}
                      >
                        <TeamOutlined
                          style={{ fontSize: "32px", color: "#ccc" }}
                        />
                        <div style={{ marginTop: "8px" }}>
                          <Text type="secondary">
                            参加クリエイターが登録されていません
                          </Text>
                        </div>
                      </div>
                    )}
                  </div>
                </Space>
              </div>
            </Card>
          </Col>

          {/* サイドバー情報 */}
          <Col xs={24} lg={8}>
            <Space direction="vertical" size="middle" style={{ width: "100%" }}>
              {/* 基本情報カード */}
              <Card title="イベント情報" size="small">
                <Space
                  direction="vertical"
                  size="small"
                  style={{ width: "100%" }}
                >
                  <div>
                    <Text type="secondary">イベントID:</Text>
                    <Text style={{ marginLeft: "8px" }}>{event.id}</Text>
                  </div>
                  <div>
                    <Text type="secondary">開始日時:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {formatDate(event.startDate)}
                    </Text>
                  </div>
                  <div>
                    <Text type="secondary">終了日時:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {formatDate(event.endDate)}
                    </Text>
                  </div>
                  <div>
                    <Text type="secondary">会場:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {event.venue.name}
                    </Text>
                  </div>
                  <div>
                    <Text type="secondary">参加クリエイター数:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {event.creatorEvents.length}人
                    </Text>
                  </div>
                  <div>
                    <Text type="secondary">登録日:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {new Date(event.createdAt).toLocaleDateString("ja-JP")}
                    </Text>
                  </div>
                  <div>
                    <Text type="secondary">最終更新:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {new Date(event.updatedAt).toLocaleDateString("ja-JP")}
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
                  <Button type="primary" block icon={<CalendarOutlined />}>
                    参加申し込み
                  </Button>
                  <Button block icon={<EnvironmentOutlined />}>
                    会場詳細を見る
                  </Button>
                  <Button block icon={<TeamOutlined />}>
                    クリエイター一覧
                  </Button>
                </Space>
              </Card>

              {/* イベントステータス */}
              <Card title="イベントステータス" size="small">
                <div style={{ textAlign: "center" }}>
                  {scheduleStatus === "future" ? (
                    <div>
                      <Tag
                        color="green"
                        style={{ fontSize: "14px", padding: "4px 12px" }}
                      >
                        開催予定
                      </Tag>
                      <div style={{ marginTop: "8px" }}>
                        <Text type="secondary">このイベントは開催予定です</Text>
                      </div>
                    </div>
                  ) : scheduleStatus === "past" ? (
                    <div>
                      <Tag
                        color="red"
                        style={{ fontSize: "14px", padding: "4px 12px" }}
                      >
                        開催済み
                      </Tag>
                      <div style={{ marginTop: "8px" }}>
                        <Text type="secondary">このイベントは終了しました</Text>
                      </div>
                    </div>
                  ) : (
                    <div>
                      <Tag
                        color="orange"
                        style={{ fontSize: "14px", padding: "4px 12px" }}
                      >
                        開催中
                      </Tag>
                      <div style={{ marginTop: "8px" }}>
                        <Text type="secondary">このイベントは開催中です</Text>
                      </div>
                    </div>
                  )}
                </div>
              </Card>
            </Space>
          </Col>
        </Row>
      </div>

      <EventModal
        visible={modalVisible}
        startStep="form"
        onCancel={() => {
          setModalVisible(false);
        }}
        onSuccess={() => {
          refetch();
          setModalVisible(false);
        }}
      />
    </PageLayout>
  );
};

export default EventDetailPage;
